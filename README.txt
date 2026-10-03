AUDIO CLEANUP AUTOMATION — HOW TO USE
======================================

FIRST TIME SETUP (do this once)
---------------------------------
1. Install Docker Desktop: https://www.docker.com/products/docker-desktop
2. Open Docker Desktop and let it finish starting up
3. That's it — you're ready


EVERY TIME YOU USE IT
----------------------
1. Double-click START.command
   → A terminal window opens and everything starts automatically
   → Your browser opens at localhost:5678

2. Drop your MP3s into the "input" folder

3. In your browser, click the Play button (▶) to run the workflow

4. Wait for it to finish — check "output/processing_log.txt" to see results

5. Find your cleaned, tagged files in the "output" folder

6. When you're done, double-click STOP.command to shut everything down


NOTES
------
- Never move or rename this folder or anything inside it
- Your original files are never deleted. After a song is processed,
  its original moves from "input" to "originals" (that's normal)
- If "originals" already has a file with the same name, the new one
  gets a number added to the front of its name. Nothing is overwritten.
- If a song fails, its original stays in "input" and the log shows
  FAILED. A broken file stays in "input" and shows FAILED in the log
  every time you run it, until you remove it.
- The check only catches files with no sound at all. A damaged MP3
  that still has some sound in it has not been tested and may be
  marked complete.
- If a song couldn't be identified, it still gets cleaned — just needs manual tagging
- The finished file has the same bitrate as the original (up to 320 kbps).
  This is not the same as no quality loss: the audio is re-encoded twice
  (once to trim silence, once to even out the volume), and each time
  loses a little quality. No listening test has been done.
- If something looks wrong, just run STOP then START again


KNOWN ISSUES (not fixed yet)
-----------------------------
- The album and artist can be replaced by what the online lookup finds,
  even if the file's own tags were right
- Cover art changes from JPEG to PNG
- If "input" is empty and you run it from Claude, Claude says
  "The workflow did not return a response". Add an MP3 and try again.
- Quiet gaps in the middle of a song are cut too, not just at the start
  and end. One test song lost 8.9 seconds. Whether you can hear the
  difference is unknown.
- If you process a song with the same name again, the new finished file
  replaces the old one in "output"


FOLDER REFERENCE
-----------------
input/        ← Drop your MP3s here before running
output/       ← Finished files appear here
originals/    ← Your original files, moved here after processing
processing_log.txt ← Log of every file processed (inside output folder)

