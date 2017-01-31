--=======================================================================
-- File Name    : item_box.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 17:36:58
-- Description  : item container
-- Modify       :
--=======================================================================

local CreateNode = require "framework.node_factory"
if not ItemBox then
    ItemBox = CreateNode("ITEM_BOX", {"event", "save"})
end

function ItemBox:_Uninit()
    for id, item in pairs(self.item_list) do
        self:RemoveItemById(id)
    end
    self.item_list = nil
    self.sort_list = nil
    self.search_item_list = nil

    return 1
end

function ItemBox:_Init()
    self.sort_list = {}
    self.item_list = {}
    self.search_item_list = {}
    return 1
end

function ItemBox:IsValid()
    return self.item_list ~= nil
end

function ItemBox:AddItem(item)
    local id = item:GetId()
    self.item_list[id] = item
    table.insert(self.sort_list, item)

    local template = item:GetTemplateId()
    self:AddToSearchList(template, id, item)
end

function ItemBox:GetItemById(id)
    return self.item_list[id]
end

function ItemBox:GetItemIndexById(id)
    local index = nil
    for i, item in ipairs(self.sort_list) do
        if item:GetId() == id then
            index = i
            break
        end
    end
    return index
end

function ItemBox:RemoveItemById(id)
    local item = self:GetItemById(id)
    if not item then
        assert(false, "No Item[%d]", id)
        return
    end
    local index = self:GetItemIndexById(id)
    table.remove(self.sort_list, index)
    local template = item:GetTemplateId()
    self:RemoveFromSearchList(template, id)
    self.item_list[id] = nil
    return item
end

function ItemBox:GetItemList()
    return self.item_list
end

function ItemBox:ForEach(func)
    if not self.sort_list then
        return
    end
    local copy_tb = Util.CopyTB1(self.sort_list)
    for _, item in ipairs(copy_tb) do
        Util.SafeCall(func, item)
    end
end

function ItemBox:AddToSearchList(template, id, item)
    local template_list = self.search_item_list
    if not template_list[template] then
        template_list[template] = {}
    end
    local id_list = template_list[template]
    id_list[id] = item
    return 1
end

function ItemBox:RemoveFromSearchList(template_id, id)
    local result = 0
    local template_list = self.search_item_list
    local list = template_list[template_id]
    if not list then
        goto Exit0
    end
    list[id] = nil
    if not next(list) then
        template_list[template_id] = nil
    end
    result = 1
::Exit0::
    if result ~= 1 then
        assert(false, "Remove Search Faild Class[%s] Template[%s] ID[%s]", class_name, tostring(template_id), tostring(id))
    end
    return result
end

function ItemBox:GetItemListByTemplate(template_id)
    return self.search_item_list[template_id]
end

-- Unit Test
if arg and arg[1] == "item_box.bytes" then

    function ItemBox:Debug()
        print("sort_list")
        Util.ShowTB(self.sort_list)
        print("item_list")
        Util.ShowTB(self.item_list)
        print("search_item_list")
        Util.ShowTB(self.search_item_list)
    end

    local Debug = require("framework.debug")
    Debug:HookEvent(Debug.MODE_BLACK_LIST)
    local ItemBase = Class:New(nil, "ITEM")
    function ItemBase:_Init(id, template_id)
        self.id = id
        self.template_id = template_id
    end

    function ItemBase:GetId()
        return self.id
    end

    function ItemBase:GetTemplateId()
        return self.template_id
    end

    local TestBox = ItemBox()
    TestBox:Init()

    local test_item = ItemBase()
    test_item:Init("id", "test")
    print("=======================")
    TestBox:AddItem(test_item)
    TestBox:Debug()
    local test_item = ItemBase()
    test_item:Init("id1", "test")
    print("=======================")
    TestBox:AddItem(test_item)
    TestBox:Debug()
    local test_item = ItemBase()
    test_item:Init("id2", "test2")
    print("=======================")
    TestBox:AddItem(test_item)
    TestBox:Debug()
    print("=======================")
    TestBox:RemoveItemById("id")
    TestBox:Debug()
    print("=======================")
end

return ItemBox
