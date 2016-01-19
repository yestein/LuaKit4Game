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
    self.stack_count = nil
    self.capacity = nil
    return 1
end

function ItemNormal:_Init(id, template, count, capacity, ...)
    self.stack_count = count
    self.capacity = capacity
    return 1
end

function ItemNormal:SetCount(count)
    if self.capacity > 0 and count > self.capacity then
        count = self.capacity
    end
    local old_count = self.stack_count
    self.stack_count = count
    self:FireEvent("ITEM.COUNT_CHANGE", self:GetClassName(), self:GetTemplate(), self:GetId(), old_count, count)
    return count
end

function ItemNormal:GetAvalibleRoom()
    if self.capacity < 0 then
        return -1
    end
    return self.capacity - self.stack_count
end

function ItemNormal:GetCapacity()
    return self.capacity
end

function ItemNormal:GetStackCount()
    return self.stack_count
end

function ItemNormal:OnUse(use_num, ...)
    local stack_count = self:GetStackCount()
    if stack_count < use_num then
        return 0, "Not Enough"
    end
    local result, is_remove, reason = self:TryCall("Use", use_num, ...)
    if not result then
        return 0, "Cannot Use"
    end

    if result == 1 then
        self:FireEvent("ITEM.USE", self:GetClassName(), self:GetTemplate(), self:GetId(), use_num, ...)
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
