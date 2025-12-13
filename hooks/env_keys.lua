local util = require("util")

--- Each SDK may have different environment variable configurations.
--- This allows plugins to define custom environment variables (including PATH settings)
--- Note: Be sure to distinguish between environment variable settings for different platforms!
--- @param ctx table Context information
--- @field ctx.path string SDK installation directory
function PLUGIN:EnvKeys(ctx)
    local mainPath = ctx.path
    
    -- Get the directory containing the lx binary
    local binDir = util.getBinDirectory(mainPath)
    
    return {
        {
            key = "PATH",
            value = binDir
        }
    }
end