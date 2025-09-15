# BeeStation BYOND Configuration
# This file configures BYOND paths for different platforms

# Auto-detection will try these Wine prefixes in order (Linux only)
# Set WINE_BYOND_PREFIX environment variable to override
WINE_PREFIXES=(
    "$HOME/.wine"
    "$HOME/Games/byond"
    "$HOME/.local/share/lutris/runners/wine/*/drive_c"
    "/opt/wine-byond"
)

# Common BYOND installation paths within Wine prefixes
BYOND_WINE_PATHS=(
    "drive_c/Program Files (x86)/BYOND"
    "drive_c/Program Files/BYOND"
    "drive_c/BYOND"
)

# Windows BYOND paths (used on Windows systems)
BYOND_WINDOWS_PATHS=(
    "C:/Program Files (x86)/BYOND"
    "C:/Program Files/BYOND"
    "C:/BYOND"
)

# Additional search paths for BYOND executables
# Users can add custom paths here
CUSTOM_BYOND_PATHS=(
    # Add your custom BYOND installation paths here
    # Example: "/custom/path/to/byond"
)

# Wine executable name (auto-detected if not set)
WINE_EXECUTABLE="wine"

# Enable trusted mode by default for DreamSeeker (recommended for development)
TRUSTED_MODE=true

# Debug output (set to true for troubleshooting)
DEBUG_OUTPUT=false
