--=======================================================================
-- File Name    : module_base
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : create date
-- Description  : description
-- Modify       :
--=======================================================================
local Class = require("lib.class")
local assert = require("lib.assert")
local CreateNode = require("framework.node_factory")

if not ModuleBase then
    ModuleBase = CreateNode("MODULE_BASE", {"event", "save"})
end

function ModuleBase:_Uninit( ... )
    return 1
end

function ModuleBase:_Init()
    return 1
end

function ModuleBase:GetModuleName()
    return self.__class_name
end

return ModuleBase
