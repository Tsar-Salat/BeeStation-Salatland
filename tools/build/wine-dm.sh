#!/bin/bash
# Wine wrapper for BYOND DreamMaker
# This script allows the build system to run DreamMaker through Wine

# Set Wine prefix
export WINEPREFIX="/home/boneyards/Games/byond"

# Path to actual DreamMaker executable in Wine
DM_PATH="/home/boneyards/Games/byond/drive_c/Program Files (x86)/BYOND/bin/dm.exe"

# Run DreamMaker with Wine, passing all arguments
exec wine "$DM_PATH" "$@"
