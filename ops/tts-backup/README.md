# TTS Backup

This directory contains the scripts for backing up the TTS stack on `tts.create360.ai` and restoring it onto another machine.

## Scope

The backup covers these service directories:

- `/srv/CosyVoice`
- `/srv/ai-voice-studio`
- `/srv/index-tts-vllm`
- `/srv/index-tts-vllm-tw`

## Source Inventory

Primary local services covered by this backup:

- `CosyVoice`
- `ai-voice-studio`
- `index-tts-vllm`
- `index-tts-vllm-tw`

Documented external source:

- `外部taigiTTS`
  - Reference app: `https://huggingface.co/spaces/tbdavid2019/Taiwanese-tts/blob/main/app.py`
  - The referenced Gradio app calls the external API endpoint `https://learn-language.tokyo/taigiTTS/taigi-text-to-speech`
  - Default model in the referenced app: `model6`
  - This is tracked as an external dependency/reference and is not included in the `/srv/...` backup set unless separately mirrored

It also uploads deployment manifests:

- `docker inspect` output for the four running containers
- `docker compose config` output for the four services
- `docker image ls`
- `nvidia-smi` and basic system metadata

By default the backup also exports the four Docker images as compressed archives.

## AWS Resources

- Bucket: `create360-tts-backup-574787056615-apne1`
- Region: `ap-northeast-1`
- IAM user: `tts-backup-operator`

## Backup

Set AWS credentials for the backup user, then run:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=ap-northeast-1

./ops/tts-backup/backup_remote_tts_to_s3.sh
```

You can override the snapshot name:

```bash
./ops/tts-backup/backup_remote_tts_to_s3.sh root@tts.create360.ai 20260702T000000Z
```

To skip Docker image archives:

```bash
BACKUP_DOCKER_IMAGES=0 ./ops/tts-backup/backup_remote_tts_to_s3.sh
```

## Restore

Run on the target machine as `root` after installing Docker, Docker Compose, NVIDIA drivers, and the AWS CLI:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=ap-northeast-1

sudo ./ops/tts-backup/restore_tts_from_s3.sh 20260702T000000Z
```

Useful switches:

```bash
RESTORE_DOCKER_IMAGES=0 sudo ./ops/tts-backup/restore_tts_from_s3.sh 20260702T000000Z
START_SERVICES=0 sudo ./ops/tts-backup/restore_tts_from_s3.sh 20260702T000000Z
```
