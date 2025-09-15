#!/bin/bash
# BYOND Auto-Detection Script
# Automatically detects BYOND installations on Windows and Linux (Wine)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/byond-config.sh" 2>/dev/null || true

# Global variables for detected paths
DETECTED_WINE_PREFIX=""
DETECTED_BYOND_PATH=""
DETECTED_PLATFORM=""

debug_log() {
    if [[ "${DEBUG_OUTPUT:-false}" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

detect_platform() {
    case "$(uname -s)" in
        CYGWIN*|MINGW*|MSYS*) DETECTED_PLATFORM="windows" ;;
        Linux*) DETECTED_PLATFORM="linux" ;;
        Darwin*) DETECTED_PLATFORM="macos" ;;
        *) DETECTED_PLATFORM="unknown" ;;
    esac
    debug_log "Detected platform: $DETECTED_PLATFORM"
}

find_wine_executable() {
    local wine_cmd="${WINE_EXECUTABLE:-wine}"
    if command -v "$wine_cmd" >/dev/null 2>&1; then
        echo "$wine_cmd"
        return 0
    fi

    # Try common wine executables
    for wine_name in wine wine64 /opt/wine/bin/wine; do
        if command -v "$wine_name" >/dev/null 2>&1; then
            echo "$wine_name"
            return 0
        fi
    done

    return 1
}

find_byond_linux() {
    debug_log "Searching for BYOND in Wine installations..."

    # Check environment variable override
    if [[ -n "$WINE_BYOND_PREFIX" && -d "$WINE_BYOND_PREFIX" ]]; then
        WINE_PREFIXES=("$WINE_BYOND_PREFIX")
        debug_log "Using Wine prefix from environment: $WINE_BYOND_PREFIX"
    fi

    # Search in Wine prefixes
    for prefix in "${WINE_PREFIXES[@]}"; do
        # Expand wildcards and home directory
        for expanded_prefix in $prefix; do
            if [[ -d "$expanded_prefix" ]]; then
                debug_log "Checking Wine prefix: $expanded_prefix"

                for byond_path in "${BYOND_WINE_PATHS[@]}"; do
                    full_path="$expanded_prefix/$byond_path"
                    if [[ -d "$full_path" && -f "$full_path/bin/dm.exe" ]]; then
                        DETECTED_WINE_PREFIX="$expanded_prefix"
                        DETECTED_BYOND_PATH="$full_path"
                        debug_log "Found BYOND at: $full_path"
                        return 0
                    fi
                done
            fi
        done
    done

    return 1
}

find_byond_windows() {
    debug_log "Searching for BYOND on Windows..."

    for byond_path in "${BYOND_WINDOWS_PATHS[@]}"; do
        if [[ -d "$byond_path" && -f "$byond_path/bin/dm.exe" ]]; then
            DETECTED_BYOND_PATH="$byond_path"
            debug_log "Found BYOND at: $byond_path"
            return 0
        fi
    done

    return 1
}

find_byond_custom() {
    debug_log "Searching custom BYOND paths..."

    for byond_path in "${CUSTOM_BYOND_PATHS[@]}"; do
        if [[ -n "$byond_path" && -d "$byond_path" && -f "$byond_path/bin/dm.exe" ]]; then
            DETECTED_BYOND_PATH="$byond_path"
            debug_log "Found BYOND at custom path: $byond_path"
            return 0
        fi
    done

    return 1
}

detect_byond() {
    detect_platform

    # Try custom paths first
    if find_byond_custom; then
        return 0
    fi

    case "$DETECTED_PLATFORM" in
        "windows")
            find_byond_windows
            ;;
        "linux")
            find_byond_linux
            ;;
        *)
            debug_log "Unsupported platform: $DETECTED_PLATFORM"
            return 1
            ;;
    esac
}

get_wine_prefix() {
    echo "$DETECTED_WINE_PREFIX"
}

get_byond_path() {
    echo "$DETECTED_BYOND_PATH"
}

get_platform() {
    echo "$DETECTED_PLATFORM"
}

get_dm_executable() {
    if [[ -n "$DETECTED_BYOND_PATH" ]]; then
        echo "$DETECTED_BYOND_PATH/bin/dm.exe"
    fi
}

get_dreamseeker_executable() {
    if [[ -n "$DETECTED_BYOND_PATH" ]]; then
        echo "$DETECTED_BYOND_PATH/bin/dreamseeker.exe"
    fi
}

get_dreamdaemon_executable() {
    if [[ -n "$DETECTED_BYOND_PATH" ]]; then
        echo "$DETECTED_BYOND_PATH/bin/dreamdaemon.exe"
    fi
}

# Main detection function
main() {
    if detect_byond; then
        debug_log "BYOND detection successful"
        debug_log "Platform: $DETECTED_PLATFORM"
        debug_log "BYOND Path: $DETECTED_BYOND_PATH"
        if [[ "$DETECTED_PLATFORM" == "linux" ]]; then
            debug_log "Wine Prefix: $DETECTED_WINE_PREFIX"
        fi
        return 0
    else
        debug_log "BYOND detection failed"
        return 1
    fi
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
