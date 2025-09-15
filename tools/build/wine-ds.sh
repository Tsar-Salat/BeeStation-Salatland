#!/bin/bash
# Wine wrapper for BYOND DreamSeeker
# This script allows launching DreamSeeker through Wine

# Set Wine prefix
export WINEPREFIX="/home/boneyards/Games/byond"

# Path to actual DreamSeeker executable in Wine
DS_PATH="/home/boneyards/Games/byond/drive_c/Program Files (x86)/BYOND/bin/dreamseeker.exe"

# Run DreamSeeker with Wine, passing all arguments
exec wine "$DS_PATH" "$@"
