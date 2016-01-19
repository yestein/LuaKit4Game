--=======================================================================
-- File Name    : script_manager.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/20 11:55:10
-- Description  : description
-- Modify       :
--=======================================================================
local ScriptManager  = {
    ignore_list = {}
}

for k, _ in pairs(package.loaded) do
    ScriptManager.ignore_list[k] = 1
end

function ScriptManager:Reload(script_name)
    local function reload(script_name)
        package.loaded[script_name] = nil
        require(script_name)
    end
    if script_name then
        reload(script_name)
    else
        local ignore_list = self.ignore_list
        for script_name, _ in pairs(package.loaded) do
            if not ignore_list[script_name] then
                print("reload", script_name)
                reload(script_name)
            end
        end
    end
end

function reloadscript(script_name)
    return ScriptManager:Reload(script_name)
end

if arg and arg[1] == "script_manager" then
    local Util = require("lib.util")
    Util.ShowTB(ScriptManager.ignore_list, 1)

    reloadscript()
end

return ScriptManager
