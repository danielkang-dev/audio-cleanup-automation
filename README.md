# Audio Cleanup Automation

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
3. Double-click `START.command`. The first run builds the image, so it takes a few minutes. If the browser opens before n8n is ready, refresh the page.
4. Create the n8n owner account when prompted. It is stored locally in `n8n_data/` and never leaves your machine.
5. Import the workflow: create a new workflow, open the `⋯` menu in the top right, choose **Import from File…** and select `workflow/audio-cleanup.json`. Save it.
6. Get a free AcoustID API key at https://acoustid.org/new-application. Open the **Fingerprint and Metadata** node and replace `YOUR_ACOUSTID_API_KEY` with your key. Save again.
7. Drop MP3s into `input/` and run the workflow

End-user instructions are in `README.txt`.

## Security notes

This is built as a local, single-user tool.

- Port binding — `docker-compose.yml` publishes n8n on `127.0.0.1:5678` only, so it is not reachable from other machines on the network
- Login — on first launch n8n asks you to create an owner account (email and password), and you sign in with it after that
- `NODE_FUNCTION_ALLOW_BUILTIN=*` — Code nodes need `child_process` to call ffmpeg, fpcalc and curl. No external npm modules are used or allowed.
- AcoustID key — the workflow in this repo ships with a placeholder. Your own key is typed into the node and lives only in your local `n8n_data/`, in plain text inside the workflow.

The builtin allowance would need narrowing to what's actually used (`child_process`) before this was run on a server or exposed to a network.

`n8n_data/`, `input/`, `output/` and `processing/` are gitignored. `n8n_data/` holds `database.sqlite`, which stores credentials — it's runtime data, not source, and it's deliberately kept out of this repo.

## Repo contents

| File | Purpose |
|---|---|
| `Dockerfile` | Custom image: n8n 2.42.2 + ffmpeg + Chromaprint on `node:24-alpine` |
| `docker-compose.yml` | Container config and volume mounts |
| `workflow/audio-cleanup.json` | The nine-node n8n workflow, ready to import |
| `START.command` / `STOP.command` | One-click launch and shutdown |
| `README.txt` | End-user instructions |
| `LICENSE` | MIT licence |
