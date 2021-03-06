--=======================================================================
-- File Name    : item_buff.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/17 14:37:16
-- Description  : buff in most game
-- Modify       :
--=======================================================================

local Class = require("lib.class")
local ItemBase = require("framework.item.item_base")

if not ItemBuff then
    ItemBuff = Class:New(ItemBase, "BUFF")
end

function ItemBuff:_Uninit()
    return 1
end

function ItemBuff:_Init(id, template)
    self:SetDataByKey("luancher_list", {})
    self:SetDataByKey("capacity", 1)
    return 1
end

function ItemBuff:GetContainer()
    return self.container
end


function ItemBuff:SetContainer(container)
    self.__AddBaseValue("container", container)
end

function ItemBuff:GetOwner()
    local container = self:GetContainer()
    return container:GetParent()
end

function ItemBuff:SetCapacity(capacity)
    self:SetDataByKey("capacity", capacity)
end

function ItemBuff:SetLastsTime(lasts_time)
    self:SetDataByKey("rest_time", lasts_time)
    self:SetDataByKey("lasts_time", lasts_time)
end

function ItemBuff:GetLuancherList()
    return self:GetDataByKey("luancher_list")
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
    return self:GetDataByKey("capacity")
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
    local luancher_list = self:GetLuancherList()
    if not luancher then
        luancher = 0
    end
    if not luancher_list[luancher] then
        luancher_list[luancher] = 0
    end
    for i = 1, count do
        luancher_list[luancher] = luancher_list[luancher] + 1
        self:TryCall("TriggerAddEffect", luancher)
    end
    self:FireEvent("ADD", self:GetId(), self:GetTemplateId(), self:GetOwner():GetId(), luancher, cur_count, cur_count + count)
    return cur_count + count
end

function ItemBuff:RemoveStackCount(count, buff_luancher)
    local rest_count = count
    local luancher_list = self:GetLuancherList()
    local sum_remove_count = 0
    local function RemoveFromLuancher(luancher)
        local num = luancher_list[luancher]
        if num > rest_count then
            num = rest_count
        end
        for i = 1, num do
            self:TryCall("TriggerRemoveEffect", luancher)
            luancher_list[luancher] = luancher_list[luancher] - 1
            rest_count = rest_count - 1
        end
        if luancher_list[luancher] == 0 then
            luancher_list[luancher] = nil
        end
        return num
    end
    if not buff_luancher then
        for luancher, num in pairs(luancher_list) do
            sum_remove_count = sum_remove_count + RemoveFromLuancher(luancher)
        end
    else
        sum_remove_count = RemoveFromLuancher(buff_luancher)
    end
    self:FireEvent("REMOVE", self:GetId(), self:GetTemplateId(), self:GetOwner():GetId(), sum_remove_count)
    return rest_count
end

function ItemBuff:TimerActive()
    local is_remove = 0
    local rest_time = self:GetDataByKey("rest_time")
    if rest_time and rest_time > 0 then
        rest_time = rest_time - 1
        self:SetDataByKey("rest_time", rest_time)
        self:TriggerTickEffect()
        if rest_time == 0 then
            is_remove = 1
        end
    end

    return is_remove
end

function ItemBuff:ResetTimer()
    return self:SetDataByKey("rest_time", self:GetDataByKey("lasts_time"))
end

function ItemBuff:GetRestTime()
    return self:GetDataByKey("rest_time")
end

--Unit Test
if arg and arg[1] == "item_buff" then
    local Debug = require("framework.debug")
    Debug:HookEvent(Debug.MODE_BLACK_LIST)
    local item1 = ItemBuff()
    item1:Init("1", "test")
    item1:SetCapacity(3)
    item1:AddStackCount("wang2", 1)
    item1:AddStackCount("zhang3", 1)
    item1:AddStackCount("li4", 1)
    item1:RemoveStackCount(3, "zhang3")
    print("count", item1:GetStackCount())
    item1:RemoveStackCount(3)
    print("count", item1:GetStackCount())
    local Util = require("lib.util")
    Util.ShowTB(item1:GetLuancherList())
    local item2 = ItemBuff()
    function item2:Active()
        print("Active", self:GetRestTime())
    end
    item2:Init("1", "test")
    item2:SetCapacity(1)
    item2:SetLastsTime(20)
    item2:AddStackCount("zhang3", 1)
    item2:AddStackCount("li4", 1)
    print("count", item2:GetStackCount())
    Util.ShowTB(item2:GetLuancherList())
    local reset = 10
    while item2 do
        if reset == 0 then
            item2:ResetTimer()
        end
        item1:TryCall("Active")
        item2:TryCall("Active")
        local is_remove = item2:TimerActive()
        print(is_remove)
        if is_remove == 1 then
            item2:Uninit()
            item2 = nil
        end

        is_remove = item1:TimerActive()
        print(is_remove)
        if is_remove == 1 then
            item1:Uninit()
            item1 = nil
        end
        reset = reset - 1
    end
    item1:Uninit()
end

return ItemBuff
