local http = require("http")
local json = require("json")

local util = {}

--- GitHub repository information
util.GITHUB_REPO = "lumen-oss/lux"
util.GITHUB_API_URL = "https://api.github.com/repos/" .. util.GITHUB_REPO .. "/releases"
util.GITHUB_DOWNLOAD_URL = "https://github.com/" .. util.GITHUB_REPO .. "/releases/download"

--- Get the current operating system type
--- @return string osType: "windows", "linux", or "darwin"
function util.getOsType()
    return RUNTIME.osType
end

--- Get the current architecture type
--- @return string archType: "amd64", "arm64", "386", etc.
function util.getArchType()
    return RUNTIME.archType
end

--- Check if current OS is Windows
--- @return boolean
function util.isWindows()
    return RUNTIME.osType == "windows"
end

--- Check if current OS is macOS
--- @return boolean
function util.isMacOS()
    return RUNTIME.osType == "darwin"
end

--- Check if current OS is Linux
--- @return boolean
function util.isLinux()
    return RUNTIME.osType == "linux"
end

--- Fetch available releases from GitHub API
--- @return table|nil releases: Array of release objects, or nil on error
--- @return string|nil error: Error message if request failed
function util.fetchReleases()
    local resp, err = http.get({
        url = util.GITHUB_API_URL,
        headers = {
            ["Accept"] = "application/vnd.github.v3+json",
            ["User-Agent"] = "vfox-plugin-lux"
        }
    })
    
    if err ~= nil then
        return nil, "Failed to fetch releases: " .. err
    end
    
    if resp.status_code ~= 200 then
        return nil, "GitHub API returned status " .. resp.status_code
    end
    
    local releases = json.decode(resp.body)
    return releases, nil
end

--- Filter releases to only include CLI releases (vX.Y.Z format)
--- @param releases table Array of release objects
--- @return table filteredReleases: Array of CLI release objects
function util.filterCliReleases(releases)
    local filtered = {}
    for _, release in ipairs(releases) do
        local tag = release.tag_name
        -- Match only vX.Y.Z pattern (not lux-lib-* or other tags)
        if tag and string.match(tag, "^v[0-9]+%.[0-9]+%.[0-9]+$") then
            table.insert(filtered, release)
        end
    end
    return filtered
end

--- Extract version number from tag (removes 'v' prefix)
--- @param tag string Tag name like "v0.22.2"
--- @return string version: Version without prefix like "0.22.2"
function util.extractVersion(tag)
    if tag and string.sub(tag, 1, 1) == "v" then
        return string.sub(tag, 2)
    end
    return tag
end

--- Get the architecture string for download URLs
--- @return string archString: Architecture string for asset names
function util.getArchString()
    local arch = RUNTIME.archType
    if arch == "amd64" then
        return "x86_64"
    elseif arch == "arm64" then
        return "aarch64"
    else
        return arch
    end
end

--- Get platform-specific download information for a version
--- @param version string Version number (e.g., "0.22.2")
--- @return table|nil info: Download info table with url and filename
--- @return string|nil error: Error message if platform not supported
function util.getDownloadInfo(version)
    local osType = util.getOsType()
    local arch = RUNTIME.archType
    local archString = util.getArchString()
    local baseUrl = util.GITHUB_DOWNLOAD_URL .. "/v" .. version
    
    local url, filename
    
    if osType == "windows" then
        if arch == "amd64" then
            -- Windows uses MSI, will be extracted in PostInstall via msiexec
            filename = "lx_" .. version .. "_x64_en-US.msi"
            url = baseUrl .. "/" .. filename
        else
            return nil, "Unsupported architecture for Windows: " .. arch
        end
    elseif osType == "darwin" then
        if arch == "amd64" or arch == "arm64" then
            filename = "lux-cli_" .. version .. "_" .. archString .. ".dmg"
            url = baseUrl .. "/" .. filename
        else
            return nil, "Unsupported architecture for macOS: " .. arch
        end
    elseif osType == "linux" then
        if arch == "amd64" then
            -- Linux x64 uses portable tar.gz
            filename = "lx-x86_64-unknown-linux-gnu.tar.gz"
            url = baseUrl .. "/" .. filename
        elseif arch == "arm64" then
            -- Linux arm64 uses portable tar.gz
            filename = "lx-aarch64-unknown-linux-gnu.tar.gz"
            url = baseUrl .. "/" .. filename
        else
            return nil, "Unsupported architecture for Linux: " .. arch
        end
    else
        return nil, "Unsupported operating system: " .. osType
    end
    
    return {
        url = url,
        filename = filename,
        version = version
    }, nil
end

--- Get the binary name for the current platform
--- @return string binaryName: "lx.exe" on Windows, "lx" otherwise
function util.getBinaryName()
    if util.isWindows() then
        return "lx.exe"
    else
        return "lx"
    end
end

--- Find the lx binary in the installation directory
--- @param rootPath string The root installation directory
--- @return string|nil binaryPath: Path to the binary, or nil if not found
function util.findBinary(rootPath)
    local binaryName = util.getBinaryName()
    local osType = util.getOsType()
    
    -- Common locations to check
    local paths = {
        rootPath .. "/" .. binaryName,
        rootPath .. "/bin/" .. binaryName,
        rootPath .. "/usr/bin/" .. binaryName,
    }
    
    -- Windows MSI extracted paths (msiexec extracts to extracted/PFiles/lux-cli/)
    if osType == "windows" then
        table.insert(paths, rootPath .. "/extracted/PFiles/lux-cli/" .. binaryName)
        table.insert(paths, rootPath .. "/PFiles/lux-cli/" .. binaryName)
        table.insert(paths, rootPath .. "/lux-cli/" .. binaryName)
    end
    
    -- macOS app bundle specific paths
    if osType == "darwin" then
        table.insert(paths, rootPath .. "/lux-cli.app/Contents/MacOS/lx")
        table.insert(paths, rootPath .. "/Applications/lux-cli.app/Contents/MacOS/lx")
    end
    
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            file:close()
            return path
        end
    end
    
    return nil
end

--- Get the directory containing the binary for PATH
--- @param rootPath string The root installation directory
--- @return string binDir: Directory to add to PATH
function util.getBinDirectory(rootPath)
    local binaryPath = util.findBinary(rootPath)
    if binaryPath then
        -- Return directory containing the binary
        return string.match(binaryPath, "(.+)/[^/]+$") or rootPath
    end
    
    -- Default locations based on OS
    local osType = util.getOsType()
    if osType == "darwin" then
        return rootPath .. "/lux-cli.app/Contents/MacOS"
    elseif osType == "windows" then
        return rootPath .. "/extracted/PFiles/lux-cli"
    else
        return rootPath
    end
end

return util