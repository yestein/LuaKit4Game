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
local assert = require "lib.assert"

function LuaSegment:_Init(lua_expression)
    self.expression = lua_expression
    self.env = {}
    self.call_func = load(self.expression, self.expression, "t", self.env)
    assert(self.call_func, self.expression)
    Util.SetPrintValue(self, string.format("L'Seg[%s]", self.expression))
    return 1
end

function LuaSegment:_Uninit()
    self.expression = nil
    return 1
end

function LuaSegment:GetExpression()
    return self.expression
end

function LuaSegment:Eval(runtime_env)
    local f = load(self.expression, self.expression, "t", runtime_env or _ENV)
    assert(f, self.expression)
    return select(2, Util.SafeCall(f))
end

function LuaSegment:SetEnv(runtime_env)
    for k, v in pairs(runtime_env) do
        self.env[k] = v
    end
end

function LuaSegment:GetEnv(runtime_env)
    return self.env
end

function LuaSegment:Eval2(runtime_env)
    if runtime_env then
        self:SetEnv(runtime_env)
    end
    local function traceBack(s)
        print("Expression:",self.expression)
        print("Env:", Util.GetTBData(self.env, 2))
        print(debug.traceback(s, 2))
    end
    return select(2, xpcall(self.call_func, traceBack))
end

local function NewLuaSegment(lua_expression)
    if not lua_expression or lua_expression == "" then
        return
    end
    local segment = Class:Instance(LuaSegment)
    segment:Init(lua_expression)
    return segment
end

--Unit Test
if arg and arg[1] == "lua_segment.bytes" then
    local env = {
        author = "Yestein",
        reader = "Qiqi",
        hello = "Hello",
        assert = assert,
        say = function(speaker, target, word)
            print(string.format("%s say \"%s\" to %s", speaker, word, target))
            return true
        end,
    }
    local segment = NewLuaSegment("return say(author, reader, hello)")
    print(segment)
    print(segment:Eval(env))

    local segment_error = NewLuaSegment("say(assert(false))")
    print(segment_error:Eval(env))

    local segment_no_return = NewLuaSegment("say(author, reader, hello)")
    print(segment_no_return:Eval(env))


    local segment_null = NewLuaSegment("")
    print(segment_null and segment_null:Eval(env))

    --Runtime Test
    local segment_test_effect = NewLuaSegment("say(author, reader, hello)")
    print(segment_test_effect:Eval(env))

    local old_time = os.clock()
    local new_time
    local time_diff
    local eval_time_1 = 0
    local eval_time_2 = 0
    for i = 1, 100 do
        old_time = os.clock()
        env.say = function() end
        for i = 1, 1000 do
            segment_test_effect:Eval(env)
        end
        new_time = os.clock()
        time_diff = new_time - old_time
        eval_time_1 = eval_time_1 + time_diff

        old_time = os.clock()
        for i = 1, 1000 do
            segment_test_effect:Eval2(env)
        end
        new_time = os.clock()
        time_diff = new_time - old_time
        eval_time_2 = eval_time_2 + time_diff
    end
    print(eval_time_1, eval_time_2)
end

return NewLuaSegment
