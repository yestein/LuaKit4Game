--=======================================================================
-- File Name    : logic_base_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 9:48:20
-- Description  : all logic node's base
-- Modify       :
--=======================================================================


local Class = require("lib.class")
local Util = require("lib.util")
local assert = require("lib.assert")

local handler_list = {
    event = require("framework.handler.event_handler"),
    save = require("framework.handler.save_handler"),
    fsm = require("framework.handler.fsm")
}

if not LogicBaseNode then
    LogicBaseNode = Class:New(nil, "LOGIC_BASE_NODE")
end

function LogicBaseNode:_Init( ... )
    local import_handler_list = self.import_handler_list
    if import_handler_list then
        for name, handler in pairs(import_handler_list) do
            handler.Init(self, ...)
        end
    end
    return 1
end

function LogicBaseNode:_Uninit( ... )
    for name, handler in pairs(self.import_handler_list) do
        handler.Uninit(self, ...)
    end

    self:UnRegistAllTimer()
    self.timer_id_list = nil

    self:UninitChild()
    self:UnregistAllEventListen()
    self.child_list = nil
    self.is_debug = nil

    return 1
end

function LogicBaseNode:ImportHandler(name)
    local handler = handler_list[name]
    if not handler then
        assert(false)
        return
    end
    local import_handler_list = rawget(self, "import_handler_list")
    if not import_handler_list then
        self.import_handler_list = {}
        import_handler_list = self.import_handler_list
    end
    import_handler_list[name] = handler

    if not handler.import_function then
        return
    end
    for func_name, func in pairs(handler.import_function) do
        if not self[func_name] then
            self[func_name] = func
        else
            assert(false, func_name)
        end
    end
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
        child:TryCall("Uninit")
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
    child.__AddBaseValue("__parent", self)
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

function LogicBaseNode:Print(log_level, fmt, ...)
    local log_node = self:GetChild("log")
    if not log_node then
        log_print(fmt, ...)
        return
    end
    log_node:Print(log_level, fmt, ...)
end

function LogicBaseNode:LoadTimer(timer_name, timer)
    if not self.timer_list then
        self.timer_list = {}
    end
    self.timer_list[timer_name] = timer
end

function LogicBaseNode:GetTimer(timer_name)
    local timer = self.timer_list[timer_name]
    if not self.timer_id_list then
        self.timer_id_list = {}
    end
    if not self.timer_id_list[timer_name] then
        self.timer_id_list[timer_name] = {}
    end
    return timer, self.timer_id_list[timer_name]
end

function LogicBaseNode:RegistTimer(timer_name, time, ...)
    local timer, timer_id_list = self:GetTimer(timer_name)
    if not timer then
        assert(false, timer_name)
        return
    end
    local timer_id = timer:RegistTimer(time, ...)
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
    if not self.timer_id_list then
        return
    end
    for timer_name, timer_id_list in pairs(self.timer_id_list) do
        local timer = self.timer_list[timer_name]
        for timer_id, _ in pairs(timer_id_list) do
            timer:CloseTimer(timer_id)
        end
        self.timer_id_list[timer_name] = nil
    end
end

--Unit Test
if arg and arg[1] == "logic_base_node" then
    local Debug = require("framework.debug")
    local a = LogicBaseNode.New()
    a:ImportHandler("event")
    LogicBaseNode:ImportHandler("event")
    function LogicBaseNode:testListen(p, q)
        print(self:GetEventInfo())
        print(p, q)
    end
    function a:testListen(p, q)
        self:FireEvent("TEST_TRIGGER_2", 3, 5)
        print("test", self:GetEventInfo())
    end
    print(LogicBaseNode, a)
    LogicBaseNode:RegistEventListen("TEST_TRIGGER", "testListen")
    LogicBaseNode:RegistEventListen("TEST_TRIGGER_2", "testListen")
    a:RegistEventListen("TEST_TRIGGER", "testListen")
    Debug:HookEvent(Debug.MODE_BLACK_LIST)
    LogicBaseNode:FireEvent("TEST_TRIGGER", 1, "a")
    LogicBaseNode:FireEvent("TEST_TRIGGER", 2)
    LogicBaseNode:FireEvent("TEST_TRIGGER", 3)

end

return LogicBaseNode
