--=======================================================================
-- File Name    : timer_handler.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 06/08/2016 17:33:39
-- Description  : description
-- Modify       :
--=======================================================================

if not TimerHandler then
    TimerHandler = {}
end

function TimerHandler:LoadTimer(timer_name, timer)
    if not self.timer_list then
        self.timer_list = {}
    end
    self.timer_list[timer_name] = timer
end
TimerHandler:LoadTimer("real", require("unity.slua_timer"))

function TimerHandler.Init(parent)

end

function TimerHandler.Uninit(parent)
    parent:UnRegistAllTimer()
    parent.timer_id_list = nil
end

TimerHandler.import_function = {
    GetTimer = function(self, timer_name)
        local timer = TimerHandler.timer_list[timer_name]
        if not self.timer_id_list then
            self.timer_id_list = {}
        end
        if not self.timer_id_list[timer_name] then
            self.timer_id_list[timer_name] = {}
        end
        return timer, self.timer_id_list[timer_name]
    end,

    RegistTimer = function(self, timer_name, time, callback)
        local timer, timer_id_list = self:GetTimer(timer_name)
        if not timer then
            assert(false, "No [%s] timer", timer_name)
            return
        end
        local timer_id
        local debug_info = debug.traceback()
        timer_id = timer:RegistTimer(time,
            function()
                self:UnregistTimer(timer_name, timer_id)
                Util.SafeCallWithTraceback(callback, debug_info)
            end
        )
        if timer_id then
            timer_id_list[timer_id] = 1
        end
        return timer_id
    end,

    UnregistTimer = function(self, timer_name, timer_id)
        local timer, timer_id_list = self:GetTimer(timer_name)
        if not timer then
            assert(false, timer_name)
            return
        end
        timer:CloseTimer(timer_id)
        timer_id_list[timer_id] = nil
    end,

    UnRegistAllTimer = function(self)
        if not self.timer_id_list then
            return
        end
        for timer_name, timer_id_list in pairs(self.timer_id_list) do
            local timer = TimerHandler.timer_list[timer_name]
            for timer_id, _ in pairs(timer_id_list) do
                timer:CloseTimer(timer_id)
            end
            self.timer_id_list[timer_name] = nil
        end
    end,
}

--Unit Test
if arg and arg[1] == "timer_handler.bytes" then

end

return TimerHandler
