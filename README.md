# vfox-plugin-lux

A [vfox](https://vfox.dev/) plugin for managing [Lux](https://github.com/lumen-oss/lux) - a fast and efficient Lua package manager.

## Installation

```bash
# Add the plugin
vfox add lux

# Or install from source
vfox add --source https://github.com/lumen-oss/vfox-plugin-lux/releases/download/latest/vfox-plugin-lux.zip
```

## Usage

```bash
# List available versions
vfox search lux

# Install a specific version
vfox install lux@0.22.2

# Install the latest version
vfox install lux@latest

# Use a version globally
vfox use -g lux@0.22.2

# Use a version in current session
vfox use lux@0.22.2
```

## Supported Platforms

| Platform | Architecture          | Status |
| -------- | --------------------- | ------ |
| Windows  | x64                   | ✅     |
| Linux    | x64                   | ✅     |
| Linux    | arm64                 | ✅     |
| macOS    | x64 (Intel)           | ✅     |
| macOS    | arm64 (Apple Silicon) | ✅     |

## Notes

- The Lux CLI binary is named `lx`, not `lux`
- On Windows, you may need to [enable a x64 hosted MSVC toolset](https://learn.microsoft.com/en-us/cpp/build/how-to-enable-a-64-bit-visual-cpp-toolset-on-the-command-line?view=msvc-170) for full functionality
- On macOS, since Lux is not notarized, you may need to configure Gatekeeper to allow usage

## Verification

After installation, verify it works:

```bash
lx help
```

## Resources

- [Lux Documentation](https://lux.lumen-labs.org/)
- [Lux GitHub Repository](https://github.com/lumen-oss/lux)
- [vfox Documentation](https://vfox.dev/)

## License

Apache 2.0
