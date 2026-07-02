#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: sudo $0 <snapshot_name> [host_slug]" >&2
  exit 1
fi

SNAPSHOT_NAME="$1"
HOST_SLUG="${2:-tts.create360.ai}"
BUCKET="${BUCKET:-create360-tts-backup-574787056615-apne1}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"
PREFIX="hosts/${HOST_SLUG}/snapshots/${SNAPSHOT_NAME}"
RESTORE_DOCKER_IMAGES="${RESTORE_DOCKER_IMAGES:-1}"
START_SERVICES="${START_SERVICES:-1}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root so the script can restore into /srv." >&2
  exit 1
fi

services=(
  "CosyVoice:/srv/CosyVoice"
  "ai-voice-studio:/srv/ai-voice-studio"
  "index-tts-vllm:/srv/index-tts-vllm"
  "index-tts-vllm-tw:/srv/index-tts-vllm-tw"
)

images=(
  cosyvoice3_latest.tar.gz:cosyvoice3:latest
  ai-voice-studio-ai-voice-studio_latest.tar.gz:ai-voice-studio-ai-voice-studio:latest
  index-tts-server_latest.tar.gz:index-tts-server:latest
  index-tts-server-tw_latest.tar.gz:index-tts-server-tw:latest
)

for entry in "${services[@]}"; do
  label="${entry%%:*}"
  target_dir="${entry#*:}"
  mkdir -p "${target_dir}"
  aws s3 sync "s3://${BUCKET}/${PREFIX}/files${target_dir}" "${target_dir}" --only-show-errors
  echo "Restored ${label} into ${target_dir}"
done

if [[ "${RESTORE_DOCKER_IMAGES}" == "1" ]]; then
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  for entry in "${images[@]}"; do
    archive_name="${entry%%:*}"
    image_ref="${entry#*:}"
    archive_path="${tmpdir}/${archive_name}"

    if aws s3 ls "s3://${BUCKET}/${PREFIX}/images/${archive_name}" >/dev/null 2>&1; then
      aws s3 cp "s3://${BUCKET}/${PREFIX}/images/${archive_name}" "${archive_path}" --only-show-errors
      gunzip -c "${archive_path}" | docker load
      echo "Loaded ${image_ref}"
    else
      echo "Skipping missing image archive: ${archive_name}"
    fi
  done
fi

if [[ "${START_SERVICES}" == "1" ]]; then
  docker compose -f /srv/CosyVoice/docker-compose.yml up -d
  docker compose -f /srv/ai-voice-studio/docker-compose.yaml up -d
  docker compose -f /srv/index-tts-vllm/docker-compose.yaml up -d
  docker compose -f /srv/index-tts-vllm-tw/docker-compose.yaml up -d
fi

echo "Restore completed from s3://${BUCKET}/${PREFIX}"
