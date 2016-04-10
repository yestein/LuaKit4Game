--=======================================================================
-- File Name    : lua_segment.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 11/04/2016 07:02:11
-- Description  : lua segment with runtime env in table config
-- Modify       :
--=======================================================================
local Class = require("lib.class")
local Util = require("lib.util")
local LuaSegment = Class:New(nil, "LUA_SEGMENT")

function LuaSegment:_Init(lua_expression)
    self.expression = lua_expression
    return 1
end

function LuaSegment:_Uninit()
    self.expression = nil
    return 1
end

function LuaSegment:GetExpression()
    return self.expression
end

function LuaSegment:Run(runtime_env)
    local f = load(self.expression, "lua segment", "t", runtime_env or _ENV)
    local success, result = Util.SafeCall(f)
    if not success then
        return
    end
    return result
end

local function NewLuaSegment(lua_expression)
    local segment = Class:New(LuaSegment)
    segment:Init(lua_expression)
    return segment
end

--Unit Test
if arg and arg[1] == "lua_segment" then
    local env = {
        author = "Yestein",
        reader = "Qiqi",
        hello = "Hello",
        say = function(speaker, target, word)
            print(string.format("%s say \"%s\" to %s", speaker, word, target))
        end,
    }
    local segment = NewLuaSegment("return say(author, reader, hello)")
    segment:Run(env)
end

return NewLuaSegment
