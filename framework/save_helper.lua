--=======================================================================
-- File Name    : save_helper.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 24/11/2016 22:08:29
-- Description  : description
-- Modify       :
--=======================================================================

local Class = require "lib.class"
local Util = require "lib.util"

if not SaveHelper then
    SaveHelper = Class:New(nil, "SaveHelper")
end

local DEFAULT_FILE = "./default.sav"

function SaveHelper:_Uninit()
    self.save_func = nil
    self.load_func = nil
    self.save_data = nil
end

function SaveHelper:_Init()
    self.save_func = {}
    self.load_func = {}
    self.save_data = {}

    self.is_load = false
end

function SaveHelper:DefaultSave()
    Util.SaveFile(DEFAULT_FILE, Util.Table2Str(self.save_data))
end

function SaveHelper:DefaultLoad()
    return Util.Str2Val(Util.LoadFile(DEFAULT_FILE))
end

function SaveHelper:AddSaveFunc(kind, func)
    self.save_func[kind] = func
end

function SaveHelper:AddLoadFunc(kind, func)
    self.load_func[kind] = func
end

function SaveHelper:Save(kind, k, v)
    self.save_data[k] = v
    local save_func = self.save_func[kind]
    if save_func then
        return save_func(k, v)
    end
    self:DefaultSave()
end

function SaveHelper:Load(kind, k)
    local load_func = self.load_func[kind]
    if load_func then
        return load_func(k, v)
    end
    if not self.is_load then
        self.is_load = true
        self.save_data = self:DefaultLoad()
    end
    return self.save_data[k]
end

--Unit Test
if arg and arg[1] == "save_helper.bytes" then
    SaveHelper:Init()

    SaveHelper:Save("int", "i", 1)
    SaveHelper:Save("string", "w", "test")

    SaveHelper:Uninit()

    SaveHelper:Init()
    print(SaveHelper:Load("int", "i"))
    print(SaveHelper:Load("string", "w"))
end

return SaveHelper
