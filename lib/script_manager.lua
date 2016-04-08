--=======================================================================
-- File Name    : script_manager.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/20 11:55:10
-- Description  : description
-- Modify       :
--=======================================================================

if not G_ScriptManager then
    G_ScriptManager  = {
        ignore_list = {}
    }

    for k, _ in pairs(package.loaded) do
        G_ScriptManager.ignore_list[k] = 1
    end
end

local ScriptManager = G_ScriptManager

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

if arg and arg[1] == "script_manager" then
    local Util = require("lib.util")
    Util.ShowTB(ScriptManager.ignore_list, 1)

    ScriptManager:Reload()
end

return ScriptManager
