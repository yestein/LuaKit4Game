--=======================================================================
-- File Name    : item_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 9:46:32
-- Description  : item base class
-- Modify       :
--=======================================================================
local Class = require("lib.class")
local assert = require("lib.assert")
local LogicBaseNode = require("framework.logic_base_node")

local ItemBase = Class:New(LogicBaseNode, "ITEM_BASE")

function ItemBase:_Uninit(...)
    self.template = nil
    self.id = nil
    return 1
end

function ItemBase:_Init(id, template, ...)
    self.id = id
    self.template = template
    return 1
end

function ItemBase:GetId()
    return self.id
end

function ItemBase:GetTemplate()
    return self.template
end

--Unit Test
if arg and arg[1] == "item_base" then
    local item = Class:New(ItemBase)
    item:Init("1", "test")
    print(item:GetId(11))
    print(item:GetTemplate(1))
    item:Uninit()
end

return ItemBase
