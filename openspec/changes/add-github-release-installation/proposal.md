# Change: Add GitHub Release Installation for Lux CLI

## Why

The vfox-plugin-lux project currently uses template placeholder code and doesn't implement actual installation of the Lux CLI package manager. Users need a functional vfox plugin to install and manage multiple versions of Lux from GitHub releases (https://github.com/lumen-oss/lux/releases).

## What Changes

- Implement `Available` hook to fetch available versions from GitHub releases API
- Implement `PreInstall` hook to construct download URLs for platform-specific binaries
- Implement `PostInstall` hook to handle post-installation extraction (Windows MSI/EXE, macOS DMG, Linux AppImage/tar.gz/deb)
- Implement `EnvKeys` hook to configure PATH for the installed Lux binary
- Update `metadata.lua` with proper plugin information
- Create utility functions for platform detection and GitHub API interactions

## Impact

- Affected specs: None (new capability)
- Affected code: `metadata.lua`, `hooks/available.lua`, `hooks/pre_install.lua`, `hooks/post_install.lua`, `hooks/env_keys.lua`, `lib/util.lua`
