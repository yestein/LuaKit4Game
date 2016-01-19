--=======================================================================
-- File Name    : logic_base_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 9:48:20
-- Description  : all logic node's base
-- Modify       :
--=======================================================================

local LuaEvent = require("framework.event")
local Class = require("lib.class")
local Util = require("lib.util")
local assert = require("lib.assert")

local LogicBaseNode = Class:New(nil, "LOGIC_BASE_NODE")

function LogicBaseNode:_Init( ... )
    self.timer_list = {}
    return 1
end

function LogicBaseNode:_Uninit( ... )
    self:UnRegistAllTimer()
    self.timer_list = nil

    self:UninitChild()
    self:UnregistAllEventListen()
    self.child_list       = nil
    self.reg_event_list   = nil
    self.is_debug          = nil

    return 1
end

function LogicBaseNode:EnableDebug(is_debug)
    self.is_debug = is_debug
end

function LogicBaseNode:IsDebug()
    return self.is_debug
end

function LogicBaseNode:UninitChild()
    if not self.child_list then
        return
    end
    for name, child in pairs(self.child_list) do
        child:ReceiveMessage("Uninit")
    end
    self.child_list = nil
end

function LogicBaseNode:GetParent()
    return self.__parent
end

function LogicBaseNode:AddChild(child_name, child)
    if not self.child_list then
        self.child_list = {}
    end

    assert(not self.child_list[child_name])
    self.child_list[child_name] = child
    child.__parent = self
    assert(self:RegistChildMessageHandlerByName(child_name) == 1)
end

function LogicBaseNode:RemoveChild(child_name)
    if not self.child_list then
        return
    end
    assert(self.child_list[child_name])
    self.child_list[child_name] = nil
end

function LogicBaseNode:GetChild(child_name)
    if not self.child_list then
        return
    end
    return self.child_list[child_name]
end

function LogicBaseNode:ForEachChild(callback, ...)
    if not self.child_list then
        return
    end

    for child_name, child_node in pairs(self.child_list) do
        callback(child_name, child_node, ...)
    end
end

function LogicBaseNode:QueryFunction(func_name, result)
    local func = self[func_name]
    if func and type(func) == "function" then
        result[#result + 1] = {func, self}
    end
    if not self.child_list then
        return
    end

    self:ForEachChild(
        function(name, child)
            if not child.QueryFunction then
                return
            end
            child:QueryFunction(func_name, result)
        end
    )
end

function LogicBaseNode:Exec(func_name, ...)
    local result = {}
    self:QueryFunction(func_name, result)
    for _, info in pairs(result) do
        Util.SafeCall(info[1], info[2], self, ...)
    end
end

function LogicBaseNode:FireEvent(event_name, ...)
    LuaEvent:SetTrigger(self)
    LuaEvent:FireEvent(event_name, ...)
end

function LogicBaseNode:RegistEventListen(event_type, func_name)
    if not self.reg_event_list then
        self.reg_event_list = {}
    end
    if not self.reg_event_list[event_type] then
        self.reg_event_list[event_type] = {}
    end
    local id_reg = LuaEvent:RegistEvent(event_type, self[func_name], self)
    self.reg_event_list[event_type][id_reg] = 1
    return id_reg
end

function LogicBaseNode:UnregistEventListen(event_type, id_reg)
    if not self.reg_event_list then
        assert(false)
        return
    end
    if not self.reg_event_list[event_type] then
        assert(false)
        return
    end

    if not self.reg_event_list[event_type][id_reg] then
        assert(false)
        return
    end

    LuaEvent:UnRegistEvent(event_type, id_reg)
    self.reg_event_list[event_type][id_reg] = nil
end

function LogicBaseNode:UnregistAllEventListen()
    if not self.reg_event_list then
        return
    end
    for event_type, id_list in pairs(self.reg_event_list) do
        for id_reg, _ in pairs(id_list) do
            LuaEvent:UnRegistEvent(event_type, id_reg)
        end
    end
    self.reg_event_list = {}
end

function LogicBaseNode:Print(log_level, fmt, ...)
    local log_node = self:GetChild("log")
    if not log_node then
        log_print(fmt, ...)
        return
    end
    log_node:Print(log_level, fmt, ...)
end

function LogicBaseNode:LoadTimer(timer_name, timer)
    self.timer_list[timer_name] = {timer, {}}
end

function LogicBaseNode:GetTimer(timer_name)
    local timer_info = self.timer_list[timer_name]
    if timer_info then
        return timer_info[1], timer_info[2]
    end
end

function LogicBaseNode:OnTimer(timer_id_list, callback, timer_id)
     if timer_id then
        timer_id_list[timer_id] = nil
    end
    Util.SafeCall(callback)
end

function LogicBaseNode:RegistTimer(timer_name, frame, callback)
    local timer, timer_id_list = self:GetTimer(timer_name)
    if not timer then
        assert(false, timer_name)
        return
    end
    local timer_id = timer:RegistTimer(frame, self.OnTimer, self, timer_id_list, callback)
    if timer_id then
        timer_id_list[timer_id] = 1
    end
    return timer_id
end

function LogicBaseNode:UnregistTimer(timer_name, timer_id)
    local timer, timer_id_list = self:GetTimer(timer_name)
    if not timer then
        assert(false, timer_name)
        return
    end
    timer:CloseTimer(timer_id)
    timer_id_list[timer_id] = nil
end

function LogicBaseNode:UnRegistAllTimer()
    for timer_name, timer_info in pairs(self.timer_list) do
        local timer, timer_id_list = timer_info[1], timer_info[2]
        for timer_id, _ in pairs(timer_id_list) do
            timer:CloseTimer(timer_id)
        end
        timer_info[2] = {}
    end
end

--Unit Test
if arg and arg[1] == "logic_base_node" then
    local Debug = require("framework.debug")
    function LogicBaseNode:testListen(p)
        print(LuaEvent:GetTrigger(), p)
    end
    LogicBaseNode:RegistEventListen("TEST_TIRGGER", "testListen")
    Debug:HookEvent(Debug.MODE_BLACK_LIST)
    LuaEvent:FireEvent("TEST_TIRGGER", 1)
    LogicBaseNode:FireEvent("TEST_TIRGGER", 2)
    LuaEvent:FireEvent("TEST_TIRGGER", 3)
end

return LogicBaseNode
