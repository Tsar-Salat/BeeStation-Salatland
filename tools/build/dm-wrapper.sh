#!/bin/bash
# Generic BYOND DreamMaker wrapper
# Auto-detects BYOND installation and runs dm.exe appropriately for the platform

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/byond-detect.sh"

if ! detect_byond; then
    echo "Error: Could not find BYOND installation." >&2
    echo "Please ensure BYOND is installed and accessible." >&2
    echo "For Linux: Make sure BYOND is installed in Wine" >&2
    echo "For Windows: Make sure BYOND is installed normally" >&2
    echo "" >&2
    echo "You can also set custom paths in tools/build/byond-config.sh" >&2
    exit 1
fi

DM_EXECUTABLE="$(get_dm_executable)"
PLATFORM="$(get_platform)"

case "$PLATFORM" in
    "windows")
        # On Windows, run dm.exe directly
        exec "$DM_EXECUTABLE" "$@"
        ;;
    "linux")
        # On Linux, run through Wine
        WINE_PREFIX="$(get_wine_prefix)"
        WINE_CMD="$(find_wine_executable)"

        if [[ -z "$WINE_CMD" ]]; then
            echo "Error: Wine not found. Please install Wine to use BYOND on Linux." >&2
            exit 1
        fi

        export WINEPREFIX="$WINE_PREFIX"
        exec "$WINE_CMD" "$DM_EXECUTABLE" "$@"
        ;;
    *)
        echo "Error: Unsupported platform: $PLATFORM" >&2
        exit 1
        ;;
esac
