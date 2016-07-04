--=======================================================================
-- File Name    : debug.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 15:46:54
-- Description  : debug system
-- Modify       :
--=======================================================================

local Event = require("framework.event")
local Log = require("lib.log")
local Util = require("lib.util")

if not Dbg then
    Dbg = {
        watch_event_list = {},
        watch_event_black_list = {},
    }
end

Dbg.MODE_BLACK_LIST = 1
Dbg.MODE_WHITE_LIST = 2

function Dbg:PrintEvent(event_type, ...)
    local text = Util.TransArgs2Str(...)
    local final_text = Log:ParseText("[%d]Event\t%s\t%s", self.frame_func and self.frame_func() or 0, event_type, text)
    return Log:Print(Log.LOG_INFO, "[%d]Event\t%s\t%s", self.frame_func and self.frame_func() or 0, event_type, text)
end

function Dbg:AddBlackEvent(event_type, log_level)
    self.watch_event_black_list[event_type] = log_level or Log.LOG_DEBUG
end

function Dbg:ClearBlackEvent()
    for k, v in pairs(self.watch_event_black_list) do
        self.watch_event_black_list[k] = nil
    end
end

function Dbg:AddWhiteEvent(event_type, log_level)
    self.watch_event_list[event_type] = log_level or Log.LOG_DEBUG
end

local EVENT_WATCHER = {
    [Dbg.MODE_BLACK_LIST] = function(event_type, ...)
        if not Dbg.watch_event_black_list[event_type] then
            Dbg:PrintEvent(event_type, ...)
        end
    end,
    [Dbg.MODE_WHITE_LIST] = function(event_type, ...)
        if Dbg.watch_event_list[event_type] then
            Dbg:PrintEvent(event_type, ...)
        end
    end,
}
function Dbg:SetFrameFunc(frame_func)
    self.frame_func = frame_func
end

function Dbg:HookEvent(mode)
    Event:RegistHook(EVENT_WATCHER[mode])
end

--Unit Test
if arg and arg[1] == "debug" then
    local function foo()
        return 43
    end
    Dbg:SetFrameFunc(foo)
    Dbg:HookEvent(Dbg.MODE_BLACK_LIST)
    Event:FireEvent("TEST", 1, nil, "test", {}, function() print(1) end)
end

return Dbg
