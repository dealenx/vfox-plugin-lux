local util = require("util")

--- Return all available versions provided by this plugin
--- @param ctx table Empty table used as context, for future extension
--- @return table Descriptions of available versions and accompanying tool descriptions
function PLUGIN:Available(ctx)
    local releases, err = util.fetchReleases()
    
    if err ~= nil then
        print("Error fetching releases: " .. err)
        return {}
    end
    
    if releases == nil then
        return {}
    end
    
    -- Filter to only CLI releases (vX.Y.Z format)
    local cliReleases = util.filterCliReleases(releases)
    
    local versions = {}
    for _, release in ipairs(cliReleases) do
        local version = util.extractVersion(release.tag_name)
        local note = ""
        
        -- Check if this is the latest release
        if #versions == 0 then
            note = "latest"
        end
        
        -- Check for prerelease or draft status
        if release.prerelease then
            note = "prerelease"
        end
        
        table.insert(versions, {
            version = version,
            note = note
        })
    end
    
    return versions
end