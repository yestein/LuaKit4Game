--=======================================================================
-- File Name    : table_parser.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/16 18:55:31
-- Description  : parse config
-- Modify       :
--=======================================================================
local Util = require("lib.util")
local assert = require("lib.assert")
local NewFormula = require("lib.formula")


local PARSE_TXT_FUNC_LIST = {
    str = function(v)
        return v
    end,

    lua = function(v)
        return Util.Str2Val(v)
    end,

    num = function(v)
        return tonumber(v) or 0
    end,

    formula = function(v, row_data, raw_line_no, table_data, gen_env_func)
        return NewFormula(v, row_data, raw_line_no, table_data, gen_env_func)
    end,

    static_formula = function(v, row_data, raw_line_no, table_data, gen_env_func)
        return NewFormula(v, row_data, raw_line_no, table_data, gen_env_func):CalcValue()
    end,

    comment = function(v)
        return nil
    end,
}

local copy_parse_tb = Util.CopyTB(PARSE_TXT_FUNC_LIST, 1)
for k, v in pairs(copy_parse_tb) do
    if k ~= "comment" then
        PARSE_TXT_FUNC_LIST["param_" .. k] = v
    end
end
copy_parse_tb = nil



local TableParser = {}

function TableParser.GetParser(value_type)
    return PARSE_TXT_FUNC_LIST[value_type]
end

function TableParser.RemoveQuote(value)
    local len = #value
    local result = value
    if value:sub(1, 1) == "\"" and value:sub(len, len) == "\"" then
        result = value:sub(2, len - 1)
    end
    return result
end

function TableParser.Parse(value_type, value, ...)
    local parser = TableParser.GetParser(value_type)
    if not parser then
        assert(false, "No Type Trans Func[%s]", tostring(value_type))
        return
    end
    value = TableParser.RemoveQuote(value)

    return parser(value, ...)
end

--Unit Test
if arg and arg[1] == "table_parser" then

end

return TableParser

