local util = require("util")

--- Extension point, called after PreInstall, can perform additional operations,
--- such as file operations for the SDK installation directory or compile source code
function PLUGIN:PostInstall(ctx)
    local rootPath = ctx.rootPath
    local osType = util.getOsType()
    local binaryName = util.getBinaryName()
    
    -- Find the binary in the installation directory
    local binaryPath = util.findBinary(rootPath)
    
    if binaryPath == nil then
        print("Warning: Could not find " .. binaryName .. " binary in " .. rootPath)
        print("You may need to manually locate and configure the binary.")
        return
    end
    
    -- Set executable permissions on Unix systems
    if osType == "linux" or osType == "darwin" then
        local result = os.execute("chmod +x \"" .. binaryPath .. "\"")
        if result ~= 0 and result ~= true then
            print("Warning: Failed to set executable permissions on " .. binaryPath)
        end
    end
    
    print("Lux CLI installed successfully at: " .. binaryPath)
end