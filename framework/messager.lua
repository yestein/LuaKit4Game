--=======================================================================
-- File Name    : co
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : coroutine
-- Description  : 18/05/2016 14:49:44
-- Modify       :
--=======================================================================

local assert = require "lib.assert"

if not Messager then
    local Class = require("lib.class")
    Messager = Class:New(nil, "MESSAGER")
end

-- local IS_DEBUG = true

local LuaEvent = require "framework.event"

function Messager:Run(main_function, ...)
    self.co = coroutine.create(main_function)
    local result, err_msg = coroutine.resume(self.co, ...)
    if not result then
        print(err_msg)
    end
end

function Messager:Wait(wait_message)
    self.wait_message = wait_message
    if IS_DEBUG then
        print("Wait", wait_message)
    end
    return coroutine.yield()
end

function Messager:WaitEvent(wait_event)
    local reg_id = nil
    reg_id = LuaEvent:RegistEvent(wait_event, function(env_func, ...)
        LuaEvent:UnRegistEvent(wait_event, reg_id)
        local result, err_msg = coroutine.resume(self.co, ...)
        if not result then
            print(err_msg)
        end
        return result
    end)
    if IS_DEBUG then
        print("Wait Event", wait_event)
    end
    return coroutine.yield()
end

function Messager:WaitTargetEvent(target, wait_event)
    local reg_id = nil
    reg_id = LuaEvent:RegistTargetEvent(target, wait_event, function(env_func, ...)
        LuaEvent:UnRegistTargetEvent(target, wait_event, reg_id)
        local result, err_msg = coroutine.resume(self.co, ...)
        if not result then
            print(err_msg)
        end
        return result
    end)
    if IS_DEBUG then
        print("Wait Target Event", target, wait_event)
    end
    return coroutine.yield()
end

function Messager:Send(send_message, ...)
    if IS_DEBUG then
        print("Receive", send_message, ...)
    end
    if send_message ~= self.wait_message then
        print("Wait ".. self.wait_message, "But Receive " .. send_message)
        print(debug.traceback())
        return
    end
    self.wait_message = nil
    local result, err_msg = coroutine.resume(self.co, ...)
    if not result then
        print(err_msg)
    end
    return result
end

--Unit Test
if arg and arg[1] == "messager.bytes" then
    local LuaEvent = require "framework.event"
    local t1 = "tt1"
    local t2 = "tt2"
    local m1 = Messager()
    m1:Run(function()
        print("M1 start")
        m1:WaitTargetEvent(t1, "HELLO")
        print("M1 over")
    end)

    print("Main Resume")

    local m2 = Messager()
    m2:Run(function()
        print("M2 start")
        m2:WaitTargetEvent(t1, "HELLO")
        print("M2 over")
    end)

    print("Main Resume")

    LuaEvent:FireEvent(t1, "HELLO")
    LuaEvent:FireEvent(t2, "HELLO")

end

return Messager

