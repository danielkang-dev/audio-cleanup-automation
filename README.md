# Audio Cleanup Automation - n8n audio pipeline

A self-contained, Dockerised pipeline that cleans, normalises and auto-tags MP3 files. Built with n8n, ffmpeg and AcoustID fingerprinting. Designed to be handed to a non-technical user as a folder they double-click.

## What it does

Drop MP3s into `input/`, run one workflow, get back files with:

- Silence trimmed from the start and end
- Loudness normalised to −14 LUFS (two-pass loudnorm)
- Metadata auto-tagged via AcoustID fingerprint matching — title, artist, album, year
- A processing log recording what matched and what needs manual tagging

Tagging is limited by the AcoustID database. If a track isn't listed there, the file is still cleaned and normalised, and gets flagged in the log for manual tagging rather than guessed at.

## How it works

Nine n8n nodes, everything inside one Docker image:

```
Manual trigger → scan input → move to processing → trim silence →
normalise (analyse) → normalise (apply) → fingerprint + AcoustID lookup →
write tags and save → log and clean up
```

Each stage degrades gracefully. If trimming fails the original passes through; if loudness analysis fails it falls back to single-pass; if fingerprinting fails the file is flagged rather than mislabelled. No file is dropped and nothing is silently tagged wrong.

```
START.command  → starts Docker, launches containers, opens n8n at localhost:5678
STOP.command   → shuts everything down cleanly
```

## Requirements

- Docker Desktop (Mac, Apple Silicon)
- A free AcoustID API key, entered in n8n — not stored in this repo

## Setup

1. Install Docker Desktop
2. Clone this repo
3. Double-click `START.command`
4. Add your AcoustID API key to the fingerprint node in n8n
5. Drop MP3s into `input/` and run the workflow

End-user instructions are in `README.txt`.

## Security notes

This is built as a local, single-user tool bound to `localhost`. Two settings reflect that and are deliberate:

- `N8N_BASIC_AUTH_ACTIVE=false` — no login, because the instance is never exposed beyond the local machine
- `NODE_FUNCTION_ALLOW_BUILTIN=*` — Code nodes need `child_process` to call ffmpeg and fpcalc

Both would need tightening before this was run on a server or exposed to a network. Auth on, and the builtin allowance narrowed to what's actually used.

`n8n_data/`, `input/`, `output/` and `processing/` are gitignored. `n8n_data/` holds `database.sqlite`, which stores credentials — it's runtime data, not source, and it's deliberately kept out of this repo.

## Repo contents

| File | Purpose |
|---|---|
| `Dockerfile` | Custom image: n8n + ffmpeg + Chromaprint on `node:20-alpine` |
| `docker-compose.yml` | Container config and volume mounts |
| `START.command` / `STOP.command` | One-click launch and shutdown |
| `README.txt` | End-user instructions |
