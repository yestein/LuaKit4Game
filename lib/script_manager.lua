--=======================================================================
-- File Name    : script_manager.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/20 11:55:10
-- Description  : description
-- Modify       :
--=======================================================================

local ScriptManager =  {}
local ignore_list = {}
local reload_function = {}

require("lib.class")

for k, _ in pairs(package.loaded) do
    ignore_list[k] = 1
end

function ScriptManager.AddIgnore(name)
    ignore_list[name] = 1
end

function ScriptManager.Reload(script_name)
    local function reload(script_name)
        package.loaded[script_name] = nil
        require(script_name)
    end
    if script_name then
        reload(script_name)
    else
        local need_loaded = {}
        for script_name, _ in pairs(package.loaded) do
            if not ignore_list[script_name] then
                need_loaded[script_name] = 1
            end
        end
        for script_name, _ in pairs(need_loaded) do
            reload(script_name)
        end
    end
end

_G.GameGlobal = {}
setmetatable(_G, {
    __index = function(table, k)
        local v = rawget(table, k)
        if v then
           return v
        end
        v = table.GameGlobal[k]
        return v
    end,
    __newindex = function(tb, key, value)
        if rawget(_G, key) then
            print(string.format("[%s] conflict!", key))
        end
        tb.GameGlobal[key] = value
    end,
})

ScriptManager.AddIgnore("lib.script_manager")

if arg and arg[1] == "script_manager.bytes" then
    local Util = require("lib.util")
    Util.ShowTB(ignore_list, 1)

    ScriptManager.Reload()
    print("================")
    TESTTTTTTT = {}
    for k, v in pairs(_G.GameGlobal) do
        print(k)
    end
    ScriptManager.Reload()
    for k, v in pairs(_G.GameGlobal) do
        print(k)
    end
end

return ScriptManager
