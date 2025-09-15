# BYOND Cross-Platform Setup

This repository includes a cross-platform BYOND setup that automatically detects BYOND installations on both Windows and Linux (via Wine).

## Windows Setup

On Windows, no additional configuration is required. The system will automatically detect your BYOND installation in the standard locations:

- `C:/Program Files (x86)/BYOND`
- `C:/Program Files/BYOND`
- `C:/BYOND`

## Linux Setup (Wine)

For Linux users, you need to have BYOND installed in Wine. The system will automatically search for Wine prefixes in these locations:

- `$HOME/.wine`
- `$HOME/Games/byond`
- `$HOME/.local/share/lutris/runners/wine/*/drive_c`
- `/opt/wine-byond`

### Quick Linux Setup

1. **Install Wine** (if not already installed):
   ```bash
   sudo apt install wine  # Ubuntu/Debian
   sudo dnf install wine  # Fedora
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
│   ├── byond-config.sh          # Configuration file
│   ├── byond-detect.sh          # Auto-detection script
│   ├── dm-wrapper.sh            # DreamMaker wrapper
│   ├── dreamseeker-wrapper.sh   # DreamSeeker wrapper
│   ├── dreamdaemon-wrapper.sh   # DreamDaemon wrapper
│   ├── build-and-launch.sh      # Complete build and launch script
│   └── dm_versions.json         # Build system configuration
└── byond-wine/
    └── bin/
        ├── dm.exe              # VS Code extension wrappers
        ├── dreamseeker.exe
        └── dreamdaemon.exe
```

This setup maintains full compatibility with the original Windows workflow while adding seamless Linux support.
