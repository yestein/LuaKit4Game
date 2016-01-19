--=======================================================================
-- File Name    : frame_timer.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 21:28:46
-- Description  : timer
-- Modify       :
--=======================================================================
local Util = require("lib.util")
local Class = require("lib.class")
local Log = require("lib.log")

if not G_FrameTimer then
    G_FrameTimer = Class:New(nil, "FRAME_TIMER")
end

local Timer = G_FrameTimer

function Timer:_Uninit( ... )
    self.num_frame = nil
    self.frame_event = nil
    self.call_back_list = nil
    return 1
end

function Timer:_Init( ... )
    self.call_back_list = {}
    self.frame_event = {}
    self.num_frame = 0
    return 1
end

function Timer:Trigger(regist_obj)
    if not regist_obj then
        return
    end
    local is_success, result = Util.SafeCall(regist_obj[1])
    if not is_success then
        Log:Print(Log.LOG_ERROR, regist_obj[4])
        return
    end
    local next_frame = result
    if not next_frame then
        return
    end
    if next_frame <= 0 then
        next_frame = regist_obj[2]
    end
    self:RegistTimer(next_frame, regist_obj[1])
end

function Timer:OnActive(current_frame)
    local current_frame = self.num_frame + 1
    self.num_frame = current_frame
    local event_list = self.frame_event[current_frame]
    if not event_list then
        return
    end

    for _, timer_id in ipairs(event_list) do
        local regist_obj = self.call_back_list[timer_id]
        self.call_back_list[timer_id] = nil
        self:Trigger(regist_obj)
    end
    self.frame_event[current_frame] = nil
end

--======================================================
-- Reigist Function Return Value:
-- n > 0 : Continue Reigst a same timer n frames later
-- n <= 0: Continue Reigst a same timer with same frames last regist
-- no return or return nil: Nothing happen
--======================================================
function Timer:RegistTimer(frame, call_back)

    local trace_back = debug.traceback(nil, 2)
    local current_frame = self.num_frame
    local frame_index = current_frame + math.ceil(frame)

    local regist_obj = {call_back, frame, frame_index, trace_back}
    if frame == 0 then
        self:Trigger(regist_obj)
        return
    end

    local timer_id = #self.call_back_list + 1
    call_back[#call_back + 1] = timer_id
    self.call_back_list[timer_id] = regist_obj

    if not self.frame_event[frame_index] then
        self.frame_event[frame_index] = {}
    end
    table.insert(self.frame_event[frame_index], timer_id)
    return timer_id
end

function Timer:CloseTimer(timer_id)
    if not self.call_back_list[timer_id] then
        return
    end
    local frame_index = self.call_back_list[timer_id][3]
    self.call_back_list[timer_id] = nil
    local event_list = self.frame_event[frame_index]
    local remove_index = nil
    for index, id in ipairs(event_list) do
        if id == timer_id then
            remove_index = index
            break
        end
    end
    if remove_index then
        table.remove(event_list, remove_index)
    end
end

function Timer:CloseAllTimer()
    self.call_back_list = {}
    self.frame_event = {}
end

--Unit Test
if arg and arg[1] == "frame_timer" then
    Timer:Init()
    local function testError()
        print(a[1])
    end
    Timer:RegistTimer(1, {testError})
    local function testParam(p)
        print(p)
    end
    Timer:RegistTimer(2, {testParam, 1})
    local function testLoop(a)
        print(a)
        return -1
    end
    Timer:RegistTimer(4, {testLoop, 2})

    for i = 1, 20 do
        print("Frame", Timer.num_frame)
        Timer:OnActive()
    end
    Timer:Uninit()
end

return Timer
