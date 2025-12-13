local util = require("util")

--- Run a Windows command and capture output
--- @param cmd string The command to execute
--- @return boolean success Whether the command succeeded
--- @return string|nil output Command output (on success) or error
local function runWindowsCommand(cmd)
    local handle = io.popen(cmd .. " 2>&1")
    if not handle then
        return false, "Failed to execute command"
    end
    local output = handle:read("*a")
    local success, exitType, code = handle:close()
    -- Lua 5.1 returns true/nil, Lua 5.2+ returns true, "exit", code
    if success == true or success == nil then
        return true, output
    end
    return false, output or ("Exit code: " .. tostring(code))
end

--- Extension point, called after PreInstall, can perform additional operations,
--- such as file operations for the SDK installation directory or compile source code
function PLUGIN:PostInstall(ctx)
    local rootPath = ctx.rootPath
    local osType = util.getOsType()
    local binaryName = util.getBinaryName()
    
    -- On Windows, extract MSI using msiexec
    if osType == "windows" then
        -- Find the MSI file
        local msiFile = nil
        -- Convert path to use backslashes for Windows commands
        local winRootPath = string.gsub(rootPath, "/", "\\")
        
        local handle = io.popen('dir /b "' .. winRootPath .. '" 2>nul')
        if handle then
            for file in handle:lines() do
                if string.match(file, "%.msi$") then
                    msiFile = winRootPath .. "\\" .. file
                    break
                end
            end
            handle:close()
        end
        
        if msiFile then
            print("Extracting MSI package...")
            print("MSI file: " .. msiFile)
            
            -- Create a subdirectory for extraction to avoid conflict with MSI location
            local extractPath = winRootPath .. "\\extracted"
            
            -- Create extraction directory
            runWindowsCommand('mkdir "' .. extractPath .. '"')
            
            -- Use msiexec with admin install mode for extraction
            local cmd = 'msiexec /a "' .. msiFile .. '" /qn TARGETDIR="' .. extractPath .. '"'
            print("Running: " .. cmd)
            
            local success, output = runWindowsCommand(cmd)
            print("Command output: " .. (output or "none"))
            
            -- Check if extraction was successful by looking for the binary
            local binaryCheck = extractPath .. "\\PFiles\\lux-cli\\lx.exe"
            local checkFile = io.open(binaryCheck, "r")
            if checkFile then
                checkFile:close()
                print("MSI extracted successfully.")
            else
                print("Warning: Binary not found at " .. binaryCheck)
                print("Trying with /qb (basic UI) mode...")
                cmd = 'msiexec /a "' .. msiFile .. '" /qb TARGETDIR="' .. extractPath .. '"'
                success, output = runWindowsCommand(cmd)
                print("Result: " .. (output or "none"))
            end
        else
            print("Warning: No MSI file found in " .. winRootPath)
        end
    end
    
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