--=======================================================================
-- File Name    : module_mgr
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Thu Mar 27 16:16:44 2014
-- Description  :
-- Modify       :
--=======================================================================

local Class = require("lib.class")
local assert = require("lib.assert")

if not G_ModuleMgr then
    G_ModuleMgr = {
        module_list = {},
    }
end

local ModuleMgr = G_ModuleMgr
local ModuleBase = require("framework.module_base")

function ModuleMgr:NewModule(module_name)
    local class_module = Class:New(ModuleBase, module_name)
    self:_AddModule(module_name, class_module)
    return class_module
end

function ModuleMgr:_AddModule(module_name, class_module)
    self.module_list[module_name] = class_module
end

function ModuleMgr:GetModule(module_name)
    return self.module_list[module_name]
end

--Unit Test
if arg and arg[1] == "module_mgr" then
    local Util = require("lib.util")
    local module_tes = ModuleMgr:NewModule("test")
    module_tes:Init()
    Util.ShowTB(module_tes, 2)
end


return ModuleMgr



