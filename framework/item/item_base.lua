--=======================================================================
-- File Name    : item_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 9:46:32
-- Description  : item base class
-- Modify       :
--=======================================================================
local Class = require("lib.class")
local assert = require("lib.assert")
local CreateNode = require("framework.node_factory")

local ItemBase = CreateNode("ITEM_BASE", {"event"})
ItemBase:__AddInheritFunctionOrder("OnCreate")
ItemBase:__AddInheritFunctionOrder("OnUse")
ItemBase:__AddInheritFunctionOrder("OnDrop")
ItemBase:__AddInheritFunctionOrder("OnDestroy")

function ItemBase:_Uninit(...)
    self:OnDestroy()
    self.data = nil
    return 1
end

function ItemBase:_Init(id, template, ...)
    self:SetDataByKey("id", id)
    self:SetDataByKey("template", template)
    return 1
end

function ItemBase:GetId()
    return self:GetDataByKey("id")
end

function ItemBase:GetTemplate()
    return self:GetDataByKey("template")
end

--Unit Test
if arg and arg[1] == "item_base" then
    local item = Class:New(ItemBase)
    item:Init("1", "test")
    print(item:GetId())
    print(item:GetTemplate())
    item:Uninit()
end

return ItemBase
