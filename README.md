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
8. Optional, to run it from Claude: import `workflow/audio-cleanup-mcp.json` the same way. The imported wrapper does not know which workflow to run, because workflow IDs differ between installs. Open the **run_audio_cleanup** node, click the **Workflow** field, choose **From list**, and pick **Audio Cleanup**. Then set the bearer token on the **MCP Server Trigger** node (create a new Bearer Auth credential; the token is not stored in this repo) and save.

End-user instructions are in `README.txt`.

## Run it from Claude

Once step 8 of Setup is done, Claude can run the cleanup for you. Instead of opening n8n and clicking a button, you drop MP3s into `input/` and ask Claude to clean them up.

1. Make sure the app is running (double-click `START.command`) and the **Audio Cleanup MCP** workflow is switched to **Active** in n8n.
2. Connect Claude Code to it. In a terminal, run this once, replacing `YOUR_TOKEN` with the token you set in n8n:

   ```
   claude mcp add --transport http audio-cleanup http://127.0.0.1:5678/mcp/audio-cleanup --header "Authorization: Bearer YOUR_TOKEN"
   ```

3. Check it worked: `claude mcp list` should show `audio-cleanup` as **Connected**.
4. Drop one or more MP3s into `input/`, then ask Claude: "Run the audio cleanup." Claude uses the `run_audio_cleanup` tool and reports each file and whether tags were found.

Cleaned files appear in `output/`, and `output/processing_log.txt` records what happened.

Things to know:

- The address only works on your own computer (`127.0.0.1`), and every request needs the token. Keep the token out of this repo. A gitignored file such as `.env.mcp` is a good place for it.
- The tool takes no options. It processes every MP3 in `input/`.
- It takes a while, since the tool only replies once every file is finished. In a test on an Apple Silicon Mac, two MP3s (5.8 MB and 8.7 MB) took about 40 seconds in total, roughly 20 seconds per file. Start with a few files and expect longer for bigger folders.

## Known behaviour

- Empty input folder — if `input/` has no MP3s when the workflow runs from Claude, the tool reports `The workflow did not return a response`. This is expected, not a fault: the scan finds nothing and stops quietly. Drop in at least one MP3 and run it again.

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
| `workflow/audio-cleanup.json` | The n8n audio workflow, ready to import: the nine processing nodes plus a trigger that lets another workflow call it |
| `workflow/audio-cleanup-mcp.json` | Two-node MCP wrapper that exposes the audio workflow to Claude as `run_audio_cleanup` |
| `START.command` / `STOP.command` | One-click launch and shutdown |
| `README.txt` | End-user instructions |
| `LICENSE` | MIT licence |
