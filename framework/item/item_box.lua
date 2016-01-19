--=======================================================================
-- File Name    : item_box.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 17:36:58
-- Description  : item container
-- Modify       :
--=======================================================================

local Class = require("lib.class")
local assert = require("lib.assert")
local Log = require("lib.log")

local ItemNormal = require("framework.item.item_normal")
local ItemBox = Class:New(ItemNormal, "ITEM_BOX")

function ItemBox:_Uninit()
    return 1
end

function ItemBox:_Init()
    self.item_list = {}
    self.search_item_list = {}
    return 1
end

function ItemBox:AddItem(item)
    local id = item:GetId()
    self.item_list[id] = item

    local class_name = item:GetClassName()
    local template = item:GetTemplate()
    self:AddToSearchList(class_name, template, id)
    self:FireEvent("ITEM_BOX.ADD_ITEM", class_name, template, id, item:GetStackCount())

    item:Exec("OnAdd")
    if item:GetStackCount() <= 0 then
        self:RemoveItemById(id)
    end
end

function ItemBox:GetItemById(id)
    return self.item_list[id]
end

function ItemBox:RemoveItemById(id)
    local item = self:GetItemById(id)
    if not item then
        assert(false, "No Item[%d]", id)
        return
    end
    item:Exec("OnRemove")
    self.item_list[id] = nil

    local class_name = item:GetClassName()
    local template = item:GetTemplate()
    self:RemoveFromSearchList(class_name, template, id)
    self:FireEvent("ITEM_BOX.REMOVE_ITEM", class_name, template, id, item:GetStackCount())
end

function ItemBox:AddToSearchList(class_name, template, id)
    if not self.search_item_list[class_name] then
        self.search_item_list[class_name] = {}
    end
    local template_list = self.search_item_list[class_name]
    if not template_list[template] then
        template_list[template] = {}
    end
    local id_list = template_list[template]
    id_list[id] = 1
    return 1
end

function ItemBox:RemoveFromSearchList(class_name, template, id)
    local result = 0
    local list = self:SearchItemList(class_name, template)
    if not list then
        goto Exit0
    end
    list[id] = nil
    result = 1
::Exit0::
    if result ~= 1 then
        assert(false, "Remove Search Faild Class[%s] Template[%s] Id[%s]", class_name, tostring(template), tostring(id))
    end
    return result
end

function ItemBox:SearchItemClassList(class_name)
    return self.search_item_list[class_name]
end

function ItemBox:SearchItemList(class_name, template)
    local list = nil
    local template_list = self:SearchItemClassList(class_name)
    if not template_list then
        goto Exit0
    end
    list = template_list[template]
::Exit0::
    return list
end

function ItemBox:GetItemListByTemplate(class_name, template)
    local ret = {}
    local list = self:SearchItemList(class_name, template)
    if not list then
        goto Exit0
    end

    for id, _ in pairs(list) do
        local item = self:GetItemById(id)
        if item then
            ret[#ret + 1] = item
        else
            list[id] = nil
            assert(false, "find template[%s] id[%s] not exists, have removed!", tostring(template), tostring(id))
        end
    end
::Exit0::
    return ret
end

function ItemBox:UseItemById(id, use_count, ...)
    local item = self:GetItemById(id)
    if not item then
        assert(false, "No Item[%d]", id)
        return
    end
    if not use_count then
        use_count = 1
    end
    local result, reason = item:TryCall("OnUse", use_count, ...)
    if result == 1 and item:GetStackCount() <= 0 then
        self:RemoveItemById(id)
    end
    self:FireEvent("ITEM_BOX.USE_ITEM", id, use_count, result, reason)
    return result, reason
end

-- Unit Test
if arg and arg[1] == "item_box" then
    local Debug = require("framework.debug")
    Debug:HookEvent(Debug.MODE_BLACK_LIST)
    local ItemNormal = require("framework.item.item_normal")
    ItemBox:Init()
    local test_item = Class:New(ItemNormal)
    test_item:Init(1, "test", 10, 10)
    function test_item:Use(use_count)
        print("surprise!!! * " .. use_count)
        return 1, 1
    end
    local item_id = test_item:GetId()
    print("=======================")
    ItemBox:AddItem(test_item)
    ItemBox:UseItemById(item_id, 1)
    ItemBox:RemoveItemById(item_id)
    print("=======================")
    ItemBox:AddItem(test_item)
    ItemBox:UseItemById(item_id, 9)

    local test_autouse_item = Class:New(ItemNormal)
    test_autouse_item:Init(2, "auto_use", 10, 10)
    function test_autouse_item:OnAdd()
        return self:OnUse(self:GetStackCount())
    end

    function test_autouse_item:Use(use_count)
        print("AutoUse * " .. use_count)
        return 1, 1
    end
    local autouse_item_id = test_autouse_item:GetId()
    print("=======================")
    ItemBox:AddItem(test_autouse_item)
    ItemBox:Uninit()
end

return ItemBox
