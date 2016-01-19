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

if not G_Debug then
    G_Debug = {
        watch_event_list = {},
        watch_event_black_list = {},
    }
end

local Debug = G_Debug

Debug.MODE_BLACK_LIST = 1
Debug.MODE_WHITE_LIST = 2

function Debug:PrintEvent(event_type, ...)
    local text = Util.TransArgs2Str(...)
    local final_text = Log:ParseText("[%d]Event\t%s\t%s", self.frame_func and self.frame_func() or 0, event_type, text)
    return Log:Print(Log.LOG_INFO, "[%d]Event\t%s\t%s", self.frame_func and self.frame_func() or 0, event_type, text)
end

function Debug:AddBlackEvent(event_type, log_level)
    self.watch_event_black_list[event_type] = log_level or Log.LOG_DEBUG
end

function Debug:ClearBlackEvent()
    for k, v in pairs(self.watch_event_black_list) do
        self.watch_event_black_list[k] = nil
    end
end

function Debug:AddWhiteEvent(event_type, log_level)
    self.watch_event_list[event_type] = log_level or Log.LOG_DEBUG
end

local EVENT_WATCHER = {
    [Debug.MODE_BLACK_LIST] = function(event_type, ...)
        if not Debug.watch_event_black_list[event_type] then
            Debug:PrintEvent(event_type, ...)
        end
    end,
    [Debug.MODE_WHITE_LIST] = function(event_type, ...)
        if Debug.watch_event_list[event_type] then
            Debug:PrintEvent(event_type, ...)
        end
    end,
}
function Debug:SetFrameFunc(frame_func)
    self.frame_func = frame_func
end

function Debug:HookEvent(mode)
    Event:RegistHook(EVENT_WATCHER[mode])
end

--Unit Test
if arg and arg[1] == "debug" then
    local function foo()
        return 43
    end
    Debug:SetFrameFunc(foo)
    Debug:HookEvent(Debug.MODE_BLACK_LIST)
    Event:FireEvent("TEST", 1, nil, "test", {}, function() print(1) end)
end

return Debug
