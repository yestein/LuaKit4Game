--=======================================================================
-- File Name    : event.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 10:28:34
-- Description  : description
-- Modify       :
--=======================================================================

local Util = require("lib.util")
local assert = require("lib.assert")

local Event = {
    global_event_list = {},
}


function Event:Debug()
    Util.ShowTB(self.global_event_list)
end

function Event:RegistHook(hook_function)
    self.hook_function = hook_function
end

function Event:UnRegistHook()
    self.event_black_list = nil
    self.hook_function = nil
end

function Event:RegistEvent(event_type, function_call_back, ...)
    if not event_type or not function_call_back then
        assert(false, "RegistEvent Error EventType[%s] CallBack[%s]", tostring(event_type), tostring(function_call_back))
        return
    end
    if not self.global_event_list[event_type] then
        self.global_event_list[event_type] = {}
    end
    local call_back_list = self.global_event_list[event_type]
    local register_id = #call_back_list + 1
    call_back_list[register_id] = {function_call_back, {...}}
    return register_id
end

function Event:UnRegistEvent(event_type, register_id)
    if not event_type or not register_id then
        assert(false)
        return
    end
    if not self.global_event_list[event_type] then
        return 0
    end
    local call_back_list = self.global_event_list[event_type]
    if not call_back_list[register_id] then
        return 0
    end
    call_back_list[register_id] = nil
    return 1
end

function Event:FireEvent(event_type, ...)
    if self.hook_function then
        Util.SafeCall(self.hook_function, event_type, ...)
    end
    self:CallBack(self.global_event_list[event_type], ...)
    self:SetTrigger(nil)
end

function Event:CallBack(event_list, ...)
    if not event_list then
        return
    end
    local event_list_copy = Util.CopyTB1(event_list)
    for register_id, callback in pairs(event_list_copy) do
        if event_list[register_id] then
            Util.SafeCall(callback[1], callback[2], ...)
        end
    end
end

function Event:SetTrigger(trigger)
    self.trigger = trigger
end

function Event:GetTrigger()
    return self.trigger
end

--Unit Test
if arg and arg[1] == "event" then

end

return Event
