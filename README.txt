MUSIC PIPELINE — HOW TO USE
============================

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
- The "input" folder empties automatically after processing (that's normal)
- If a song couldn't be identified, it still gets cleaned — just needs manual tagging
- If something looks wrong, just run STOP then START again


FOLDER REFERENCE
-----------------
input/        ← Drop your MP3s here before running
output/       ← Finished files appear here
processing_log.txt ← Log of every file processed (inside output folder)

