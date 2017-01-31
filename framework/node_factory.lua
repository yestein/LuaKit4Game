--=======================================================================
-- File Name    : node_factory
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 24/02/2016 19:06:08
-- Description  : create node
-- Modify       :
--=======================================================================

local Class = require("lib.class")
local assert = require("lib.assert")
local LogicBaseNode = require("framework.logic_base_node")

local function CreateNode(name, handler_list)
    local node = Class:New(LogicBaseNode, name)
    for _, name in ipairs(handler_list) do
        node:ImportHandler(name)
    end
    node:OnCreate()
    return node
end



--Unit Test
if arg and arg[1] == "node_factory.bytes" then
    local node_with_event = CreateNode("test", {"event"})
    node_with_event:FireEvent("TEST")
    print(node_with_event.FireEvent)

    local node_without_event = CreateNode("test1", {})
    print(node_without_event.FireEvent)


    local Class = require("lib.class")
    local Util = require("lib.util")
    local assert = require("lib.assert")

    local a = Class:New(CreateNode("A", {"save"}))
    a:Init()
    a:SetDataByKey("v", 1)
    a.b = Class:New(CreateNode("B", {"save"}))
    a.b:Init()
    a.b:SetDataByKey("v", 2)
    a.b.b1 = Class:New(CreateNode("B1", {"save"}))
    a.b.b1:Init()
    a.b.b1:SetDataByKey("v", 10)
    a.tb = {}
    a:SetDataByKey("test", {12,3,4,{aaa = 0, bbb = 1}})
    for i = 1, 3 do
        a.tb[i] = Class:New(CreateNode("C"..i, {"save"}))
        a.tb[i]:Init()
        a.tb[i]:SetDataByKey("c", 10 + i)
    end
    Util.ShowTB(a, 10)
    -- print(Util.GetClassData(a))
    local save_data = Class.Save(a)
    local str = Util.Table2Str(save_data)
    -- Util.ShowTB(save_data, 10)
    a = nil
    local load_data = Util.Str2Val(str)
    -- Util.ShowTB(load_data, 10)
    a = Class.Load(load_data)
    -- print(Util.GetClassData(a))
    Util.ShowTB(a, 10)
end

return CreateNode
