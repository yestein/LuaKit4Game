--=======================================================================
-- File Name    : save_handler
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 24/02/2016 18:44:11
-- Description  : help node save data
-- Modify       :
--=======================================================================

if not SaveHandler then
    SaveHandler = {}
end

function SaveHandler:Init()
    -- body
end

function SaveHandler:Uninit()

end

SaveHandler.import_function = {
    GetSaveData = function(self)
        return self:GetClassData()
    end,

    Load = function(self, load_data)
        self:SetClassData(load_data)
    end,
}

return SaveHandler
