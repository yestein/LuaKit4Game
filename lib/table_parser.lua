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
local NewLuaSegment = require("lib.lua_segment")

local PARSE_TXT_FUNC_LIST = {}
local TableParser = {}

function TableParser.AddParseRule(key, func)
    PARSE_TXT_FUNC_LIST[key] = func
    if key ~= "comment" then
        PARSE_TXT_FUNC_LIST["param_" .. key] = func
    end
end

local function ToStr(v)
    return v
end

local function ToNumber(v)
    return tonumber(v) or 0
end

local function ToComment(v)
    return nil
end

local function FormulaValue(v, row_data, raw_line_no, table_data, gen_env_func)
    return NewFormula(v, row_data, raw_line_no, table_data, gen_env_func):CalcValue()
end

local function LuaResult(v)
    if not v or v == "" then
        return nil
    end
    return NewLuaSegment("return " ..  v)
end

TableParser.AddParseRule("str", ToStr)
TableParser.AddParseRule("num", ToNumber)
TableParser.AddParseRule("comment", ToComment)
TableParser.AddParseRule("value", Util.Str2Val)
TableParser.AddParseRule("lua", NewLuaSegment)
TableParser.AddParseRule("lua_ret", LuaResult)
TableParser.AddParseRule("formula", NewFormula)
TableParser.AddParseRule("static_formula", FormulaValue)

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
if arg and arg[1] == "table_parser.bytes" then
    print(TableParser.Parse("str", "abcd"))
    print(TableParser.Parse("num", "23"))
    print(TableParser.Parse("comment", "this is comment"))
    local segment = TableParser.Parse("lua", "randomseed(seed); return random(min, max) + random(1, min)")
    print(segment)
    print(segment:Eval({seed = os.time(), randomseed = math.randomseed, random = math.random, min = 10, max = 20}))
    print(segment:Eval({seed = os.time(), randomseed = math.randomseed, random = function(a, b) return a end, min = 10, max = 20}))
    print(TableParser.Parse("value", "math.random(1,3) + 2"))

    local row_data = {a = 1, b = 2, c = "hello", d = "world"}
    local formula = TableParser.Parse("formula", "((_row.a + level) * _row.b * 10 + _random(1, 10)) .. [[ ]] .. _row.c .. [[ ]] .. _row.d", row_data, 1, {row_data},
        function()
            return {
                level = 9,
                _random = math.random,
            }
        end
    )
    print(formula)
    print(formula:CalcValue(), formula:CalcValue())
    print(TableParser.Parse("static_formula", "((_row.a + level) * _row.b * 10 + _random(1, 10)) .. [[ ]] .. _row.c .. [[ ]] .. _row.d", row_data, 1, {row_data},
        function()
            return {
                level = 9,
                _random = math.random,
            }
        end
    ))
end

return TableParser

