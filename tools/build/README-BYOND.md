# BYOND Cross-Platform Setup

This repository includes a cross-platform BYOND setup that automatically detects BYOND installations on both Windows and Linux (via Wine).

## Features

✅ **Auto-Detection**: Automatically finds BYOND installations  
✅ **Cross-Platform**: Works on Windows and Linux seamlessly  
✅ **Zero Configuration**: Works out of the box for standard installations  
✅ **Configurable**: Easy customization for non-standard setups  
✅ **VS Code Integration**: F5 build and launch works identically on all platforms  
✅ **Trusted Mode**: No file access prompts during development  

## Windows Setup

On Windows, **no additional configuration is required**. The system will automatically detect your BYOND installation in the standard locations:

- `C:/Program Files (x86)/BYOND`
- `C:/Program Files/BYOND`
- `C:/BYOND`

## Linux Setup (Wine)

For Linux users, you need to have BYOND installed in Wine. The system will automatically search for Wine prefixes in these locations:

- `$HOME/.wine` (default Wine prefix)
- `$HOME/Games/byond` (common custom prefix)
- `$HOME/.local/share/lutris/runners/wine/*/drive_c` (Lutris installations)
- `/opt/wine-byond` (system-wide installation)

### Quick Linux Setup

1. **Install Wine** (if not already installed):
   ```bash
   sudo apt install wine  # Ubuntu/Debian
   sudo dnf install wine  # Fedora
   sudo pacman -S wine    # Arch Linux
   ```

2. **Install BYOND in Wine**:
   - Download BYOND from [byond.com](https://www.byond.com/download/)
   - Run the installer with Wine:
     ```bash
     wine BYOND_installer.exe
     ```

3. **Build and run**:
   - Press `F5` in VS Code, or
   - Run `./tools/build/build-and-launch.sh`

## Architecture

The setup consists of several components:

### Core Components

1. **Detection System** (`byond-detect.sh`):
   - Auto-detects BYOND installations on Windows and Linux
   - Searches standard installation paths
   - Supports custom paths via configuration

2. **Generic Wrappers**:
   - `dm-wrapper.sh` - Cross-platform DreamMaker
   - `dreamseeker-wrapper.sh` - Cross-platform DreamSeeker (with trusted mode)
   - `dreamdaemon-wrapper.sh` - Cross-platform DreamDaemon

3. **VS Code Integration** (`tools/byond-wine/bin/`):
   - `dm.exe` - Calls the generic DreamMaker wrapper
   - `dreamseeker.exe` - Calls the generic DreamSeeker wrapper
   - `dreamdaemon.exe` - Calls the generic DreamDaemon wrapper

4. **Build System Integration**:
   - `dm_versions.json` - Configures build system to use auto-detection
   - `build-and-launch.sh` - Complete build and launch workflow

### Configuration System

The `byond-config.sh` file allows customization of:
- Wine prefix search paths
- BYOND installation search paths  
- Trusted mode settings
- Debug output settings

## Custom Configuration

You can customize the BYOND detection by editing `tools/build/byond-config.sh`:

### Environment Variables

- `WINE_BYOND_PREFIX`: Override Wine prefix location
- `DEBUG_OUTPUT`: Set to `true` for troubleshooting

Example:
```bash
export WINE_BYOND_PREFIX="/custom/wine/prefix"
export DEBUG_OUTPUT=true
```

### Custom Paths

Edit `tools/build/byond-config.sh` and add your custom paths to the `CUSTOM_BYOND_PATHS` array:

```bash
CUSTOM_BYOND_PATHS=(
    "/my/custom/byond/path"
    "/another/custom/path"
)
```

## Trusted Mode

By default, DreamSeeker runs in trusted mode for development (no file access prompts). To disable this, edit `tools/build/byond-config.sh`:

```bash
TRUSTED_MODE=false
```

## Troubleshooting

### Debug Output

Enable debug output to see what the detection system is finding:

```bash
DEBUG_OUTPUT=true ./tools/build/byond-detect.sh
```

### Manual Testing

Test the wrappers individually:

```bash
# Test DreamMaker
./tools/build/dm-wrapper.sh

# Test DreamSeeker
./tools/build/dreamseeker-wrapper.sh your_game.dmb
```

### VS Code Debugger Issues

If you see "Couldn't find a debug adapter descriptor for debug type 'byond'":

1. **Use Tasks Instead**: Press `Ctrl+Shift+P` → "Tasks: Run Task" → "Build and Launch (Linux/Wine)"
2. **Use Terminal**: Run `./tools/build/build-and-launch.sh` directly
3. **F5 Alternative**: Use `Ctrl+Shift+B` to build, then run DreamSeeker manually

The VS Code BYOND extension's debugger may have compatibility issues with Wine. The build and launch functionality works perfectly through tasks.

### Force Close Wine Processes

If you need to force close BYOND processes on Linux:

```bash
# Kill specific Wine prefix
WINEPREFIX="/path/to/prefix" wineserver -k

# Kill all dreamseeker processes
pkill -f dreamseeker
```

## VS Code Integration

The system integrates with VS Code through:

- **F5**: Build and launch (uses launch.json)
- **Ctrl+Shift+B**: Build only (uses tasks.json)
- **Ctrl+Shift+P** → "Tasks: Run Task" → "Build and Launch (Linux/Wine)"

## File Structure

```
tools/
├── build/
│   ├── byond-config.sh           # Configuration file
│   ├── byond-detect.sh           # Auto-detection script  
│   ├── dm-wrapper.sh             # Generic DreamMaker wrapper
│   ├── dreamseeker-wrapper.sh    # Generic DreamSeeker wrapper
│   ├── dreamdaemon-wrapper.sh    # Generic DreamDaemon wrapper
│   ├── build-and-launch.sh       # Complete build and launch script
│   ├── dm_versions.json          # Build system configuration
│   └── README-BYOND.md           # This documentation
└── byond-wine/
    └── bin/
        ├── dm.exe                # VS Code extension compatibility layer
        ├── dreamseeker.exe       # VS Code extension compatibility layer
        └── dreamdaemon.exe       # VS Code extension compatibility layer
```

### How It Works

1. **VS Code BYOND Extension** calls `tools/byond-wine/bin/dm.exe`
2. **Compatibility Layer** (`dm.exe`) calls `../../build/dm-wrapper.sh`
3. **Generic Wrapper** (`dm-wrapper.sh`) calls `byond-detect.sh`
4. **Detection System** finds BYOND and returns appropriate command
5. **Execution** happens via direct call (Windows) or Wine (Linux)

This architecture ensures:
- ✅ VS Code extension compatibility
- ✅ Zero configuration for standard setups
- ✅ Full customization when needed
- ✅ Cross-platform functionality

## Backwards Compatibility

This setup maintains **100% compatibility** with existing Windows workflows:
- All VS Code tasks work identically
- F5 build and launch works the same
- All keyboard shortcuts remain functional
- No changes needed to existing projects

On Linux, it provides the **exact same experience** through Wine integration.