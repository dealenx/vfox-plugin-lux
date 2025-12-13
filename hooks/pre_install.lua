local util = require("util")

--- Returns some pre-installed information, such as version number, download address, local files, etc.
--- If checksum is provided, vfox will automatically check it for you.
--- @param ctx table
--- @field ctx.version string User-input version
--- @return table Version information
function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    
    -- Get download information for the current platform
    local downloadInfo, err = util.getDownloadInfo(version)
    
    if err ~= nil then
        error("Failed to get download info: " .. err)
    end
    
    return {
        --- Version number
        version = downloadInfo.version,
        --- remote URL or local file path
        url = downloadInfo.url,
    }
end