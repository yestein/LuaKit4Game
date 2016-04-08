--=======================================================================
-- File Name    : item_normal.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/17 11:15:21
-- Description  : normal item in most game
-- Modify       :
--=======================================================================
local Class = require("lib.class")
local ItemBase = require("framework.item.item_base")

local ItemNormal = Class:New(ItemBase, "ITEM_NORMAL")

function ItemNormal:_Uninit()

    return 1
end

function ItemNormal:_Init(id, template)
    self:SetDataByKey("stack_count", 1)
    self:SetDataByKey("capacity", 1)
    return 1
end

function ItemNormal:SetCapacity(capacity)
    self:SetDataByKey("capacity", capacity)
    self:FireEvent("CAPACITY_CHANGE", self:GetClassName(), self:GetTemplate(), self:GetId(), capacity)
end

function ItemNormal:SetCount(count)
    local capacity = self:GetCapacity()
    if capacity > 0 and count > capacity then
        count = capacity
    end
    local old_count = self:GetStackCount()
    self:SetDataByKey("stack_count", count)
    self:FireEvent("COUNT_CHANGE", self:GetClassName(), self:GetTemplate(), self:GetId(), old_count, count)
    return count
end

function ItemNormal:GetAvalibleRoom()
    local capacity = self:GetCapacity()
    if capacity < 0 then
        return -1
    end
    local count = self:GetStackCount()
    return capacity - count
end

function ItemNormal:GetCapacity()
    return self:GetDataByKey("capacity")
end

function ItemNormal:GetStackCount()
    return self:GetDataByKey("stack_count")
end

function ItemNormal:_OnUse(use_num, ...)
    local stack_count = self:GetStackCount()
    if stack_count < use_num then
        return 0, "Not Enough"
    end
    local result, is_remove, reason = self:TryCall("Use", use_num, ...)
    if not result then
        return 0, "Cannot Use"
    end

    if result == 1 then
        self:FireEvent("USE", self:GetClassName(), self:GetTemplate(), self:GetId(), use_num, ...)
    end

    if is_remove == 1 then
        self:SetCount(stack_count - use_num)
    end
    return result, reason
end

--Unit Test
if arg and arg[1] == "item_normal" then
    local item = Class:New(ItemNormal)
    item:Init("1", "test", 10)
    print(item:OnUse(11))
    print(item:OnUse(1))
    item:Uninit()
end

return ItemNormal
