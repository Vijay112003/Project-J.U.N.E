@echo off

REM --- Configuration ---
set "spotify_uri=spotify:track:YOUR_SPOTIFY_TRACK_ID"  REM Replace with the actual Spotify URI of the Vijay song you want to play.  See explanation below.
set "chrome_path=C:\Program Files\Google\Chrome\Application\chrome.exe" REM Check if this is the correct path to your Chrome executable.
REM --- End Configuration ---

REM Check if Chrome executable exists
if not exist "%chrome_path%" (
    echo Error: Chrome executable not found at "%chrome_path%".
    echo Please update the chrome_path variable at the top of the script.
    pause
    exit /b 1
)

REM Open Spotify in Chrome using the specified URI
echo Opening Spotify in Chrome to play the song...
start "" "%chrome_path%" --new-window "%spotify_uri%"

echo Done. The Vijay song should start playing in Spotify in Chrome.
pause
exit /b 0