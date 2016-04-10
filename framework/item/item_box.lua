--=======================================================================
-- File Name    : item_box.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 17:36:58
-- Description  : item container
-- Modify       :
--=======================================================================

local Class = require("lib.class")
local assert = require("lib.assert")

local ItemBase = require("framework.item.item_base")
local ItemBox = Class:New(ItemBase, "ITEM_BOX")

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

    local success, need_remove = item:OnCreate()
    if need_remove == 1 then
        self:RemoveItemById(id)
    elseif need_remove == 2 then
        self:DestroyItemById(id)
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

    local class_name = item:GetClassName()
    local template = item:GetTemplate()
    self:RemoveFromSearchList(class_name, template, id)
    self.item_list[id] = nil
    return item
end

function ItemBox:GetItemList()
    return self.item_list
end

function ItemBox:DestroyItemById(id)
    local item = self:RemoveItemById(id)
    item:Uninit()
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
    local template_list = self.search_item_list[class_name]
    local list
    if not template_list then
        goto Exit0
    end
    list = template_list[template]
    if not list then
        goto Exit0
    end
    list[id] = nil
    if not next(list) then
        template_list[template] = nil
    end
    if not next(template_list) then
        self.search_item_list[class_name] = nil
    end
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

function ItemBox:UseItemById(id, ...)
    local item = self:GetItemById(id)
    if not item then
        assert(false, "No Item[%d]", id)
        return
    end
    local result, reason, need_remove = item:OnUse(...)
    if result == 1 then
        if need_remove == 1 then
            self:RemoveItemById(id)
        elseif need_remove == 2 then
            self:DestroyItemById(id)
        end
    end
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
    function test_autouse_item:OnCreate()
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
