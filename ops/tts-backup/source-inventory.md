# TTS Source Inventory

This file records the TTS sources associated with this project.

## Local Backup Scope

The following sources are part of the current file-level and image-level backup workflow:

- `CosyVoice`
- `ai-voice-studio`
- `index-tts-vllm`
- `index-tts-vllm-tw`

These are backed up from the source host `tts.create360.ai` into the S3 snapshot layout under `files/`, `manifests/`, and `images/`.

## External Sources

### `外部taigiTTS`

- Reference code: `https://huggingface.co/spaces/tbdavid2019/Taiwanese-tts/blob/main/app.py`
- Category: Taiwanese external source
- Type: external Gradio frontend / API client
- API endpoint used by the app: `https://learn-language.tokyo/taigiTTS/taigi-text-to-speech`
- Models exposed in the referenced app: `model5`, `model6`, `model7`
- Default model in the referenced app: `model6`

Notes:

- This source is not hosted under `/srv/...` on `tts.create360.ai`
- It is not part of the current backup scripts by default
- Treat it as an external dependency/reference unless you want to create a separate mirroring workflow for the Hugging Face Space or the upstream API
