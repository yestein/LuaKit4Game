--=======================================================================
-- File Name    : item_buff.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/17 14:37:16
-- Description  : buff in most game
-- Modify       :
--=======================================================================

local Class = require("lib.class")
local ItemBase = require("framework.item.item_base")

local ItemBuff = Class:New(ItemBase, "ITEM_BUFF")

function ItemBuff:_Uninit()
    self.count_list = nil
    self.capacity = nil
    self.luancher = nil
    self.owner = nil
    return 1
end

function ItemBuff:_Init(id, template, capacity, lasts_frame, ...)
    self.count_list = {}
    self.capacity = capacity
    self.lasts_frame = lasts_frame
    self.rest_frame = lasts_frame
    return 1
end

function ItemBuff:GetLuancherList()
    return self.count_list
end


function ItemBuff:GetStackCount()
    local count = 0
    local luancher_list = self:GetLuancherList()
    for luancher, num in pairs(luancher_list) do
        count = count + num
    end
    return count
end

function ItemBuff:GetCapacity()
    return self.capacity
end

function ItemBuff:AddStackCount(luancher, count)
    local cur_count = self:GetStackCount()
    local capacity = self:GetCapacity()
    local rest_room = capacity - cur_count
    if count > rest_room then
        count = rest_room
    end
    if count == 0 then
        return
    end
    if not self.count_list[luancher] then
        self.count_list[luancher] = 0
    end
    self.count_list[luancher] = self.count_list[luancher] + count
    return cur_count + count
end

function ItemBuff:RemoveStackCount(count)
    local rest_count = count
    local count_list = self.count_list
    for luancher, num in pairs(count_list) do
        if num <= rest_count then
            rest_count = rest_count - num
            count_list[luancher] = nil
        else
            count_list[luancher] = count_list[luancher] - rest_count
            rest_count = 0
        end
    end
end

function ItemBuff:TimerActive()
    local is_remove = 0
    if self.rest_frame > 0 then
        self.rest_frame = self.rest_frame - 1
        if self.rest_frame == 0 then
            is_remove = 1
        end
    end

    return is_remove
end

function ItemBuff:ResetTimer()
    self.rest_frame = self.lasts_frame
end

function ItemBuff:GetRestFrame()
    return self.rest_frame
end

--Unit Test
if arg and arg[1] == "item_buff" then
    local item1 = Class:New(ItemBuff)
    item1:Init("1", "test", 3)
    item1:AddStackCount("zhang3", 1)
    item1:AddStackCount("li4", 1)
    print("count", item1:GetStackCount())
    local Util = require("lib.util")
    Util.ShowTB(item1:GetLuancherList())
    local item2 = Class:New(ItemBuff)
    function item2:Active()
        print("Active", self:GetRestFrame())
    end
    item2:Init("1", "test", 1, 20)
    item2:AddStackCount("zhang3", 1)
    item2:AddStackCount("li4", 1)
    print("count", item2:GetStackCount())
    Util.ShowTB(item2:GetLuancherList())
    local reset = 10
    while item2 do
        reset = reset - 1
        if reset == 0 then
            item2:ResetTimer()
        end
        item1:TryCall("Active")
        item2:TryCall("Active")
        local is_remove = item2:TryCall("TimerActive")
        print(is_remove)
        if is_remove == 1 then
            item2:Uninit()
            item2 = nil
        end
    end
    item1:Uninit()
end

return ItemBuff
