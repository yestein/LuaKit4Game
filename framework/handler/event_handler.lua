--=======================================================================
-- File Name    : event_handler
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 24/02/2016 18:44:11
-- Description  : help node handle event
-- Modify       :
--=======================================================================

local LuaEvent = require("framework.event")
local assert = require "lib.assert"

if not EventHandler then
    EventHandler = {}
end

function EventHandler.Init(parent)
    parent.reg_event_list = {}
end

function EventHandler.Uninit(parent)
    parent:UnregistAllEventListen()
end

EventHandler.import_function = {
    FireEvent = function(self, event_type, ...)
        LuaEvent:FireEvent(self, self:GetEventHead() .. event_type, ...)
    end,
    FireRawEvent = function(self, event_type, ...)
        LuaEvent:FireEvent(self, event_type, ...)
    end,
    SetEventHead = function(self, event_head)
        self.__event_head = event_head .. "."
    end,

    GetEventHead = function(self)
        return self.__event_head or ""
    end,

    SetRuntimeInfo = function(self, env_func)
        self.env_func = env_func
    end,

    GetEventInfo = function(self)
        return self.env_func()
    end,

    RegistEventListen = function(self, event_type, func_name)
        assert(rawget(self, "reg_event_list"))
        if not self.reg_event_list[event_type] then
            self.reg_event_list[event_type] = {}
        end
        assert(not self.reg_event_list[event_type][func_name], "Repeat Event[%s] Regist！！Is it duplicate call??", event_type)
        local id_reg = LuaEvent:RegistEvent(event_type, self[func_name], self)
        self.reg_event_list[event_type][func_name] = id_reg
        return id_reg
    end,

    UnregistEventListen = function(self, event_type, func_name)
        assert(rawget(self, "reg_event_list"))
        if not self.reg_event_list then
            assert(false)
            return
        end
        if not self.reg_event_list[event_type] then
            assert(false)
            return
        end

        local id_reg = self.reg_event_list[event_type][func_name]
        if not id_reg then
            assert(false)
            return
        end

        LuaEvent:UnRegistEvent(event_type, id_reg)
        self.reg_event_list[event_type][func_name] = nil
    end,

    UnregistAllEventListen = function(self)
        assert(rawget(self, "reg_event_list"))
        if not self.reg_event_list then
            return
        end
        for event_type, id_list in pairs(self.reg_event_list) do
            for func_name, id_reg in pairs(id_list) do
                LuaEvent:UnRegistEvent(event_type, id_reg)
            end
        end
        self.reg_event_list = {}
    end,
}

return EventHandler
