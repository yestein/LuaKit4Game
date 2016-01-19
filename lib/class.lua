--=======================================================================
-- File Name    : class.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : date
-- Description  : simulate a table to a class in c++
--                     1. can use funciton declared in base class
--                     2. can make the call order of (Init | Uninit) like (instructor | destructor)
-- Modify       :
--=======================================================================

local Class = {}
local assert = require("lib.assert")

local function showStack(s)
    print(debug.traceback(s, 2))
end

local function AddInheritFunctionOrder(self, function_name)
    local depth = 0
    local function Inherit(self, ...)
        local execute_list = {}
        local base_class = self._tbBase
        local child_function_name = "_" .. function_name

        if Class.is_debug == 1 then
            print(string.format("%s>>%s %s Start", string.rep("  ", depth), self:GetClassName(), function_name))
        end
        depth = depth + 1
        while base_class do
            local inherit_func = rawget(base_class, child_function_name)
            if inherit_func then
                execute_list[#execute_list + 1] = {inherit_func, rawget(base_class, "__class_name")}
            end
            base_class = base_class._tbBase
        end
        for i = #execute_list, 1, -1 do
            local func, name = table.unpack(execute_list[i])
            if Class.is_debug == 1 then
                print(string.format("%s%s %s..", string.rep("  ", depth), tostring(name), function_name))
            end
            local success, result = xpcall(func, showStack, self, ...)
            if not success then
                assert(false, "[%s] Order Execute [%s] Faield!", name, function_name)
                return 0
            end
        end
        if Class.is_debug == 1 then
            print(string.format("%s%s %s..", string.rep("  ", depth), tostring(rawget(self, "__class_name")), function_name))
        end
        depth = depth - 1
        if Class.is_debug == 1 then
            print(string.format("%s!!%s %s End", string.rep("  ", depth), self:GetClassName(), function_name))
        end
        local child_func = rawget(self, child_function_name)
        if not child_func then
            return 1
        end
        local result, ret = xpcall(child_func, showStack, self, ...)
        if not result or ret ~= 1 then
            return 0
        end
        return 1
    end
    self.__AddBaseValue(function_name, Inherit)
end

local function AddInheritFunctionDisorder(self, function_name)
    local depth = 0
    local function Inherit(self, ...)
        local child_function_name = "_" .. function_name
        local child_func = rawget(self, child_function_name)
        if Class.is_debug == 1 then
            print(string.format("%s>>%s %s Start", string.rep("  ", depth), self:GetClassName(), function_name))
        end
        depth = depth + 1
        local ret_code = 1
        if child_func then
            local result, ret = xpcall(child_func, showStack, self, ...)
            if not result then
                assert(false)
                ret_code = 0
            end
        end

        local execute_list = {}
        local base_class = self._tbBase
        while base_class do
            local inherit_func = rawget(base_class, child_function_name)
            if inherit_func then
                execute_list[#execute_list + 1] = {inherit_func, rawget(base_class, "__class_name")}
            end
            base_class = base_class._tbBase
        end
        for i = 1, #execute_list do
            local func, name = table.unpack(execute_list[i])
            if Class.is_debug == 1 then
                print(string.format("%s%s %s..", string.rep("  ", depth), tostring(name), function_name))
            end
            local result, ret = xpcall(func, showStack, self, ...)
            if not result then
                assert(false, "[%s] Disorder Execute [%s] Faield!", name, function_name)
                ret_code = 0
            end
        end
        depth = depth - 1
        if Class.is_debug == 1 then
            print(string.format("%s!!%s %s End", string.rep("  ", depth), self:GetClassName(), function_name))
        end
        return ret_code
    end
    self.__AddBaseValue(function_name, Inherit)
end

local function GetClassName(self)
    return self.__class_name
end

local function TryCall(self, func_name, ...)
    local func = self[func_name]
    if not func then
        return nil
    end
    local type_func = type(func)
    if type_func == "function" then
        return func(self, ...)
    end
    local meta = getmetatable(func)
    if meta and meta.__call then
        return func(self, ...)
    end
end

function Class:New(base_class, class_name)
    local new_class = {}
    local base_value_list = {
        __GetBaseValue = function()
            return base_value_list
        end,
        _tbBase = base_class,
        __AddInheritFunctionOrder = AddInheritFunctionOrder,
        __AddInheritFunctionDisorder = AddInheritFunctionDisorder,
        GetClassName = GetClassName,
        TryCall = TryCall,
    }
    base_value_list.__AddBaseValue = function(k, v)
        base_value_list[k] = v
    end,
    setmetatable(new_class,
        {
            __index = function(table, key)
                local v = base_value_list[key]
                if v then
                    return v
                end
                v = rawget(table, key)
                if v then
                    return v
                end
                if base_class then
                    return base_class[key]
                end
            end
        }
    )
    new_class:__AddInheritFunctionOrder("Init")
    new_class:__AddInheritFunctionDisorder("Uninit")

    new_class.__class_name = class_name --查看的时候还是需要看ClassName的
    return new_class
end

function Class:EnableDebug(is_debug)
    self.is_debug = is_debug
end

--Unit test
if arg and arg[1] == "class" then
    Class:EnableDebug(1)
    local test = Class:New(nil, "aaa")
    test._Init = function(self, a, b, c, d)
       self.a = a
       self.b = b
       self.c = c
       self.d = d
    end
    test:Init(1, 2, 3, 4)
    print(test.a, test.b, test.c, test.d)

    local test_b = Class:New(test, "bbb")
    test_b._Init = function(self, a, b, c, d)
       self.a = a + 1
       self.b = b + 1
       self.c = c + 1
       self.d = d + 1
    end
    test_b:Init(1, 2, 3, 4)
    print(test_b.a, test_b.b, test_b.c, test_b.d)

    local test_name = Class:New(test)
    print(test_name:GetClassName())

    local test_call = Class:New(test)

    function test_call:test2(p)
        return p
    end

    test_call.test3 = {}

    setmetatable(test_call.test3, {
        __call = function(tb, self, p)
            return self:test2(p + 1)
        end,
    })

    print(test_call:TryCall("test1"))
    print(test_call:TryCall("test2", 1))
    print(test_call:TryCall("test3", 1))
end

return Class
