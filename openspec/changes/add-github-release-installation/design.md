# Design: GitHub Release Installation for Lux CLI

## Overview

This document describes the technical architecture for installing Lux CLI from GitHub releases using the vfox plugin system.

## GitHub Releases Structure

Lux CLI releases follow this naming pattern:

- **Release tags**: `vX.Y.Z` (e.g., `v0.22.2`) for CLI releases
- **API endpoint**: `https://api.github.com/repos/lumen-oss/lux/releases`

### Asset Naming Patterns

| Platform       | Architecture | Asset Pattern                                                    |
| -------------- | ------------ | ---------------------------------------------------------------- |
| Windows        | x64          | `lx_<version>_x64-setup.exe` or `lx_<version>_x64_en-US.msi`     |
| macOS          | x64          | `lux-cli_<version>_x86_64.dmg`                                   |
| macOS          | arm64        | `lux-cli_<version>_aarch64.dmg`                                  |
| Linux          | x64          | `lx_<version>_amd64.AppImage` or `lx_<version>_x86_64.tar.gz`    |
| Linux          | arm64        | `lx_<version>_aarch64.AppImage` or `lx_<version>_aarch64.tar.gz` |
| Linux (Debian) | x64          | `lx_<version>_amd64.deb`                                         |
| Linux (Debian) | arm64        | `lx_<version>_arm64.deb`                                         |

## Architecture Decisions

### 1. Version Fetching Strategy

**Decision**: Use GitHub API to fetch releases, filtering only `vX.Y.Z` tags (not `lux-lib-*` tags).

**Rationale**: The repository contains both `lux-cli` and `lux-lib` releases. We only want CLI versions.

### 2. Download Format Selection

**Decision**: Prioritize portable archives over installers:

- Linux: `.tar.gz` > `.AppImage` > `.deb`
- Windows: `.zip` (if available) > `.msi` > `.exe`
- macOS: `.tar.gz` (if available) > `.dmg`

**Rationale**: Portable formats work better with vfox's installation model and don't require elevated permissions.

### 3. Binary Location

**Decision**: After extraction, locate the `lx` (or `lx.exe` on Windows) binary and ensure it's accessible via PATH.

**Rationale**: The binary name is `lx`, not `lux`.

### 4. Platform Detection

Use vfox's `RUNTIME` global to detect:

- `RUNTIME.osType`: `windows`, `linux`, `darwin`
- `RUNTIME.archType`: `amd64`, `arm64`, `386`

## Component Design

### lib/util.lua

```lua
-- Platform detection helpers
function getOsType() -- returns normalized OS name
function getArchType() -- returns normalized architecture
function getDownloadUrl(version) -- constructs platform-specific URL
function fetchVersions() -- fetches from GitHub API
function filterCliReleases(releases) -- filters only vX.Y.Z tags
```

### hooks/available.lua

1. Call GitHub API: `https://api.github.com/repos/lumen-oss/lux/releases`
2. Parse JSON response
3. Filter releases with `tag_name` matching `^v[0-9]+\.[0-9]+\.[0-9]+`
4. Return list with version (without `v` prefix) and notes

### hooks/pre_install.lua

1. Receive version from context
2. Determine platform-specific download URL
3. Return download info (url, version, optional checksum)

### hooks/post_install.lua

1. Handle platform-specific extraction if needed
2. Ensure binary is in expected location
3. Set executable permissions on Unix systems

### hooks/env_keys.lua

1. Return PATH entry pointing to directory containing `lx` binary

## Error Handling

- Network failures: Return empty list/error message
- Unsupported platform: Return clear error in PreInstall
- Missing binary after install: Log warning in PostInstall

## Future Considerations

- SHA256 checksum verification (when available in releases)
- Support for installing specific assets (lux-lua libraries)
- Legacy file support for project-specific version pinning
