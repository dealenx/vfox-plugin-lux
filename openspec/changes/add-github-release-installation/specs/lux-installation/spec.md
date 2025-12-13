# Lux Installation Capability

## ADDED Requirements

### Requirement: List Available Versions

The plugin SHALL fetch available Lux CLI versions from the GitHub releases API.

#### Scenario: Successful version listing

- **GIVEN** the user has the lux plugin installed
- **WHEN** the user runs `vfox search lux`
- **THEN** the plugin fetches releases from `https://api.github.com/repos/lumen-oss/lux/releases`
- **AND** filters only releases with tags matching `v<major>.<minor>.<patch>` pattern
- **AND** returns a list of available versions in descending order

#### Scenario: GitHub API unavailable

- **GIVEN** the GitHub API is unreachable
- **WHEN** the user runs `vfox search lux`
- **THEN** the plugin returns an empty list
- **AND** logs an appropriate error message

### Requirement: Download Version

The plugin SHALL download the appropriate platform-specific binary for the requested version.

#### Scenario: Download on Windows x64

- **GIVEN** the user is on Windows x64
- **WHEN** the user runs `vfox install lux@0.22.2`
- **THEN** the plugin downloads the `lx_0.22.2_x64_en-US.msi` or portable zip asset
- **AND** extracts the `lx.exe` binary to the installation directory

#### Scenario: Download on Linux x64

- **GIVEN** the user is on Linux x64
- **WHEN** the user runs `vfox install lux@0.22.2`
- **THEN** the plugin downloads the `lx_0.22.2_x86_64.tar.gz` asset
- **AND** extracts the `lx` binary to the installation directory

#### Scenario: Download on Linux arm64

- **GIVEN** the user is on Linux arm64
- **WHEN** the user runs `vfox install lux@0.22.2`
- **THEN** the plugin downloads the `lx_0.22.2_aarch64.tar.gz` asset
- **AND** extracts the `lx` binary to the installation directory

#### Scenario: Download on macOS x64

- **GIVEN** the user is on macOS x64 (Intel)
- **WHEN** the user runs `vfox install lux@0.22.2`
- **THEN** the plugin downloads the `lux-cli_0.22.2_x86_64.dmg` asset
- **AND** extracts the application bundle to the installation directory

#### Scenario: Download on macOS arm64

- **GIVEN** the user is on macOS arm64 (Apple Silicon)
- **WHEN** the user runs `vfox install lux@0.22.2`
- **THEN** the plugin downloads the `lux-cli_0.22.2_aarch64.dmg` asset
- **AND** extracts the application bundle to the installation directory

#### Scenario: Unsupported platform

- **GIVEN** the user is on an unsupported platform/architecture combination
- **WHEN** the user runs `vfox install lux@<version>`
- **THEN** the plugin returns an error indicating the platform is not supported

### Requirement: Configure Environment

The plugin SHALL configure the PATH environment variable to include the installed binary.

#### Scenario: Set PATH after installation

- **GIVEN** the user has installed lux version 0.22.2
- **WHEN** the user runs `vfox use lux@0.22.2`
- **THEN** the PATH environment variable includes the directory containing the `lx` binary
- **AND** the user can run `lx help` successfully

### Requirement: Post-Installation Setup

The plugin SHALL perform necessary post-installation tasks.

#### Scenario: Set executable permissions on Unix

- **GIVEN** the user is on Linux or macOS
- **WHEN** the installation completes
- **THEN** the plugin sets executable permissions on the `lx` binary

#### Scenario: Handle Windows installation

- **GIVEN** the user is on Windows
- **WHEN** the installation completes
- **THEN** the `lx.exe` binary is accessible in the installation directory

## Metadata Requirements

### Requirement: Plugin Metadata

The plugin SHALL provide accurate metadata information.

#### Scenario: Plugin identification

- **GIVEN** a user wants to install the lux plugin
- **WHEN** they view plugin information
- **THEN** the plugin name is "lux"
- **AND** the homepage points to the plugin repository
- **AND** the description accurately describes the plugin's purpose
