#!/bin/bash
# Wine wrapper for BYOND DreamDaemon
# This script allows launching DreamDaemon through Wine for hosting the game locally

# Set Wine prefix
export WINEPREFIX="/home/boneyards/Games/byond"

# Path to actual DreamDaemon executable in Wine
DD_PATH="/home/boneyards/Games/byond/drive_c/Program Files (x86)/BYOND/bin/dreamdaemon.exe"

# Run DreamDaemon with Wine, passing all arguments
exec wine "$DD_PATH" "$@"
