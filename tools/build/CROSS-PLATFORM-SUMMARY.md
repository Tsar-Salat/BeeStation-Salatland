# Cross-Platform BYOND Setup - Summary

This setup provides seamless cross-platform BYOND support for the BeeStation repository, maintaining full Windows compatibility while adding robust Linux support via Wine.

## 🎯 Key Features

- **Auto-detection**: Automatically finds BYOND installations on Windows and Linux
- **Zero Configuration**: Works out of the box for most setups
- **Cross-Platform**: Same workflow on Windows and Linux
- **VS Code Integration**: F5 builds and launches just like on Windows
- **Trusted Mode**: No file access prompts during development
- **Configurable**: Easy customization for non-standard installations

## 📁 Files Added/Modified

### New Files
```
tools/build/
├── byond-config.sh          # Configuration options
├── byond-detect.sh          # Auto-detection system
├── dm-wrapper.sh            # Generic DreamMaker wrapper
├── dreamseeker-wrapper.sh   # Generic DreamSeeker wrapper
├── dreamdaemon-wrapper.sh   # Generic DreamDaemon wrapper
├── build-and-launch.sh      # Cross-platform build & launch
└── README-BYOND.md          # Setup documentation

tools/byond-wine/bin/        # VS Code extension compatibility
├── dm.exe                   # Wrapper for extension
├── dreamseeker.exe          # Wrapper for extension
└── dreamdaemon.exe          # Wrapper for extension
```

### Modified Files
```
.vscode/
├── settings.json            # Uses workspace-relative paths
├── launch.json              # Cross-platform launch config
└── tasks.json               # Updated build tasks

tools/build/
└── dm_versions.json         # Points to auto-detect wrapper
```

## 🚀 Usage

### Windows Users
- **No changes required** - everything works exactly as before
- F5 still builds and launches normally
- All existing workflows remain unchanged

### Linux Users
1. **Install Wine** (if not already installed)
2. **Install BYOND in Wine** (download from byond.com)
3. **Use normally** - F5 builds and launches

### Both Platforms
- **F5**: Build and launch with debugger
- **Ctrl+Shift+B**: Build only
- **Tasks**: "Build and Launch (Linux/Wine)" available

## 🔧 Configuration

### Environment Variables
```bash
export WINE_BYOND_PREFIX="/custom/wine/prefix"  # Override Wine prefix
export DEBUG_OUTPUT=true                        # Enable debug logging
```

### Custom Paths
Edit `tools/build/byond-config.sh`:
```bash
CUSTOM_BYOND_PATHS=(
    "/my/custom/byond/path"
    "/another/custom/path"
)
```

### Trusted Mode
Disable file access prompts by setting in `byond-config.sh`:
```bash
TRUSTED_MODE=false  # Set to false to disable
```

## 🔍 Auto-Detection Logic

### Linux (Wine)
Searches these Wine prefixes in order:
1. `$WINE_BYOND_PREFIX` (environment variable)
2. `$HOME/.wine` (default Wine prefix)
3. `$HOME/Games/byond` (custom prefix)
4. `$HOME/.local/share/lutris/runners/wine/*/drive_c` (Lutris)
5. `/opt/wine-byond` (system-wide)

Within each prefix, searches:
- `drive_c/Program Files (x86)/BYOND`
- `drive_c/Program Files/BYOND`
- `drive_c/BYOND`

### Windows
Searches standard BYOND installation paths:
- `C:/Program Files (x86)/BYOND`
- `C:/Program Files/BYOND`
- `C:/BYOND`

## 🛠️ Troubleshooting

### Debug Output
```bash
DEBUG_OUTPUT=true ./tools/build/byond-detect.sh
```

### Test Individual Components
```bash
./tools/build/dm-wrapper.sh                    # Test DreamMaker
./tools/build/dreamseeker-wrapper.sh game.dmb  # Test DreamSeeker
```

### Force Close Processes (Linux)
```bash
WINEPREFIX="/path/to/prefix" wineserver -k  # Kill Wine processes
pkill -f dreamseeker                        # Kill DreamSeeker
```

## ✅ Compatibility

- **Windows**: Full compatibility with existing workflows
- **Linux**: Requires Wine and BYOND installed in Wine
- **VS Code**: Works with existing BYOND extensions
- **Build System**: Integrates with existing Juke Build system
- **Git**: All paths are relative, safe to commit

## 🎉 Benefits

1. **Developers can use Linux** without losing BYOND functionality
2. **No platform-specific instructions** needed
3. **Same F5 experience** on all platforms
4. **Easy onboarding** for new developers
5. **Maintains Windows compatibility** 100%
6. **Configurable** for edge cases
7. **Well documented** for troubleshooting

This setup allows the repository to support both Windows and Linux developers seamlessly while maintaining the exact same development experience across platforms.
