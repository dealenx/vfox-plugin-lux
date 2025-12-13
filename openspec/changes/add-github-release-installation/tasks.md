# Tasks: Add GitHub Release Installation for Lux CLI

## 1. Implementation

- [x] **Update metadata.lua** - Set proper plugin name ("lux"), version, homepage, description, and manifest URL
- [x] **Implement lib/util.lua** - Create utility functions for platform detection and GitHub API interactions
- [x] **Implement hooks/available.lua** - Fetch and parse GitHub releases API to list available versions
- [x] **Implement hooks/pre_install.lua** - Construct platform-specific download URLs for Lux CLI binaries
- [x] **Implement hooks/post_install.lua** - Handle post-extraction tasks (permissions, binary location)
- [x] **Implement hooks/env_keys.lua** - Configure PATH environment variable for the installed binary
- [x] **Clean up unused hooks** - Remove or update `parse_legacy_file.lua`, `pre_uninstall.lua`, `pre_use.lua` if not needed

## 2. Testing

- [ ] **Test version listing** - Verify `vfox search lux` returns available versions
- [ ] **Test installation on Windows** - Verify `vfox install lux@<version>` works with MSI/ZIP
- [ ] **Test installation on Linux** - Verify installation with tar.gz/AppImage formats
- [ ] **Test installation on macOS** - Verify installation with DMG format
- [ ] **Test environment setup** - Verify `vfox use lux@<version>` correctly sets PATH

## 3. Documentation

- [x] **Update README.md** - Add usage instructions, supported platforms, and requirements

## 4. Validation

- [x] **Run openspec validate** - Ensure proposal passes validation
