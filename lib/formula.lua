--=======================================================================
-- File Name    : formula.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/16 18:36:38
-- Description  : formula use in table config
-- Modify       :
--=======================================================================
local Class = require("lib.class")
local Util = require("lib.util")
local FormulaBase = Class:New(nil, "FORMULA")

function FormulaBase:_OnCreate(exp)
    self.expression = exp
    self.env = {}
    self.call_func = load("return " .. self.expression, self.expression, "t", self.env)
    Util.SetPrintValue(self, string.format("L'Fml[%s]", self.expression))
    return 1
end

function FormulaBase:_Init(raw_row_data, raw_line_no, raw_table_data, gen_env_func)
    self.__AddBaseValue("gen_env_func", gen_env_func)
    self.__AddBaseValue("line_no", raw_line_no)
    self.__AddBaseValue("row_data", raw_row_data)
    self.__AddBaseValue("table_data", raw_table_data)
    return 1
end

function FormulaBase:_Uninit()
    self.gen_env_func = nil
    self.line_no = nil
    self.row_data = nil
    self.table_data = nil
    return 1
end

function FormulaBase:GetRunEnv()
    local ret_env = self.gen_env_func and self.gen_env_func() or {}
    ret_env._line = self.line_no
    ret_env._row = self.row_data
    ret_env._data = self.table_data
    return ret_env
end

function FormulaBase:GetExpression()
    return self.expression
end

function FormulaBase:CalcValue()
    local formula_env = self:GetRunEnv()
     for k, v in pairs(formula_env) do
        self.env[k] = v
    end
    local success, result = Util.SafeCall(self.call_func)
    if success then
        return result
    end
end

function FormulaBase:CalcValue2()
    local formula_env = self:GetRunEnv()
    local f = load("return " .. self:GetExpression(), "formula", "t", formula_env)
    assert(f, self:GetExpression())
    local success, result = Util.SafeCall(f)
    if success then
        return result
    end
end

local function NewFormula(exp, raw_row_data, raw_line_no, raw_table_data, gen_env_func)
    local formula = Class:Instance(FormulaBase, exp)
    formula:Init(raw_row_data, raw_line_no, raw_table_data, gen_env_func)
    return formula
end

--Unit Test
if arg and arg[1] == "formula.bytes" then
    local row_data = {a = 1, b = 2, c = "hello", d = "world"}
    local formula = NewFormula("((_row.a + level) * _row.b * 10 + _random(1, 10)) .. _row.c .. [[ ]] .. _row.d", row_data, 1, {row_data},
        function()
            return {
                level = 9,
                _random = math.random,
            }
        end
    )
    print(formula:CalcValue())

    local Sample = require "lib.decorator.sample"
    local Stat = Sample.Stat
    local GetStatInfo = Sample.GetStatInfo
    local cost1 =
        Stat ..
        function()
            formula:CalcValue()
        end

    for i = 1, 10000 do
        cost1()
    end

    local cost2 =
        Stat ..
        function()
            formula:CalcValue2()
        end

    for i = 1, 10000 do
        cost2()
    end
    local stat_info_1 = GetStatInfo(cost1)
    local stat_info_2 = GetStatInfo(cost2)
    print(stat_info_1.time, stat_info_2.time)
end

return NewFormula
