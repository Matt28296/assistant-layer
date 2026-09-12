@echo off
REM Starts the ASSISTANT seat from the correct folder.
REM Identity = hostname + working directory, so starting from the wrong folder makes the seat stop.
cd /d "%~dp0.."
claude
