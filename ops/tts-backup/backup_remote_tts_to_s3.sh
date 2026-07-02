#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 2 ]]; then
  echo "Usage: $0 [remote_host] [snapshot_name]" >&2
  exit 1
fi

REMOTE_HOST="${1:-root@tts.create360.ai}"
SNAPSHOT_NAME="${2:-$(date -u +%Y%m%dT%H%M%SZ)}"
BUCKET="${BUCKET:-create360-tts-backup-574787056615-apne1}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"
HOST_SLUG="${HOST_SLUG:-tts.create360.ai}"
PREFIX="hosts/${HOST_SLUG}/snapshots/${SNAPSHOT_NAME}"
BACKUP_DOCKER_IMAGES="${BACKUP_DOCKER_IMAGES:-1}"

required_vars=(
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_DEFAULT_REGION
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required environment variable: ${var_name}" >&2
    exit 1
  fi
done

read -r -d '' REMOTE_SCRIPT <<'EOF' || true
set -euo pipefail

bucket="$1"
prefix="$2"
backup_docker_images="$3"
snapshot_name="$4"

services=(
  /srv/CosyVoice
  /srv/ai-voice-studio
  /srv/index-tts-vllm
  /srv/index-tts-vllm-tw
)

images=(
  cosyvoice3:latest
  ai-voice-studio-ai-voice-studio:latest
  index-tts-server:latest
  index-tts-server-tw:latest
)

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

write_manifest() {
  local target="$1"
  shift
  "$@" > "${tmpdir}/${target}"
  aws s3 cp "${tmpdir}/${target}" "s3://${bucket}/${prefix}/manifests/${target}" --only-show-errors
}

for service_dir in "${services[@]}"; do
  if [[ ! -d "${service_dir}" ]]; then
    echo "Skipping missing service directory: ${service_dir}" >&2
    continue
  fi

  service_name="${service_dir#/}"
  aws s3 sync "${service_dir}" "s3://${bucket}/${prefix}/files/${service_name}" \
    --only-show-errors \
    --no-follow-symlinks \
    --exclude ".git/*" \
    --exclude "*/.git/*" \
    --exclude "__pycache__/*" \
    --exclude "*/__pycache__/*"
done

write_manifest system.txt bash -lc '
  echo "snapshot=${0}"
  echo "hostname=$(hostname)"
  echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "kernel=$(uname -a)"
  echo "aws_cli=$(aws --version 2>&1)"
  echo
  echo "[nvidia-smi]"
  nvidia-smi
' "${snapshot_name}"

write_manifest docker-images.txt docker image ls
write_manifest docker-inspect-cosyvoice3.json docker inspect cosyvoice3-train
write_manifest docker-inspect-ai-voice-studio.json docker inspect ai-voice-studio-app
write_manifest docker-inspect-index-tts.json docker inspect index-tts-server
write_manifest docker-inspect-index-tts-tw.json docker inspect index-tts-server-tw
write_manifest docker-compose-cosyvoice.yaml docker compose -f /srv/CosyVoice/docker-compose.yml config
write_manifest docker-compose-ai-voice-studio.yaml docker compose -f /srv/ai-voice-studio/docker-compose.yaml config
write_manifest docker-compose-index-tts.yaml docker compose -f /srv/index-tts-vllm/docker-compose.yaml config
write_manifest docker-compose-index-tts-tw.yaml docker compose -f /srv/index-tts-vllm-tw/docker-compose.yaml config

if [[ "${backup_docker_images}" == "1" ]]; then
  for image in "${images[@]}"; do
    image_slug="${image//[:\/]/_}"
    docker image save "${image}" | gzip -1 | aws s3 cp - "s3://${bucket}/${prefix}/images/${image_slug}.tar.gz" --only-show-errors
  done
fi

printf '%s\n' "${prefix}" > "${tmpdir}/latest-snapshot.txt"
aws s3 cp "${tmpdir}/latest-snapshot.txt" "s3://${bucket}/hosts/tts.create360.ai/latest-snapshot.txt" --only-show-errors
EOF

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${REMOTE_HOST}" \
  "export AWS_ACCESS_KEY_ID='${AWS_ACCESS_KEY_ID}' AWS_SECRET_ACCESS_KEY='${AWS_SECRET_ACCESS_KEY}' AWS_DEFAULT_REGION='${AWS_DEFAULT_REGION}'; bash -s -- '${BUCKET}' '${PREFIX}' '${BACKUP_DOCKER_IMAGES}' '${SNAPSHOT_NAME}'" \
  <<<"${REMOTE_SCRIPT}"

echo "Backup completed to s3://${BUCKET}/${PREFIX}"
