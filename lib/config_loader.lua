--=======================================================================
-- File Name    : config_loader.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/16 11:51:15
-- Description  : description
-- Modify       :
--=======================================================================
local Util = require("lib.util")
local Class = require("lib.class")
local Log = require("lib.log")

local TableParser = require("lib.table_parser")

local IS_ENCODE = 1
local function Encode(str_content)
    -- return core.pack(string.pack(">s2", str_content))
    return str_content
end

local function Decode(str_content)
    -- return core.unpack(string.unpack(">s2", str_content))
    return str_content
end

local function _common_title(row_data, title_name, item)
    row_data[title_name] = item
end

local function _param_title(row_data, title_name, item)
    if not row_data.__param then
        row_data.__param = {}
    end
    table.insert(row_data.__param, item)
end

local SAVE_TITLE_FUNC_LIST = {
    str = _common_title,
    num = _common_title,
    formula = _common_title,
    static_formula = _common_title,
    value = _common_title,
    lua = _common_title,
    lua_ret = _common_title,
}

local copy_save_tb = Util.CopyTB1(SAVE_TITLE_FUNC_LIST)
for k, _ in pairs(copy_save_tb) do
    SAVE_TITLE_FUNC_LIST["param_"..k] = _param_title
end
copy_save_tb = nil


local function LoadConfigLua(file_path)
    if not file_path or file_path == "" then
        return
    end
    local result
    Util.LoadFile(file_path, "a", function(str_content)
        if IS_ENCODE == 1 then
            str_content = Decode(str_content)
        end
        result = load(str_content)()
    end)
    return result
end

local function LoadConfigTable(file_path, gen_env_func)
    if not file_path or file_path == "" then
        return
    end
    local parse_result = {}
    local row = -2
    local title_list
    local value_type_list = {}

    local function parseLine(line_content)
        if line_content == "" then
            return
        end
        if IS_ENCODE == 1 then
            line_content = Decode(line_content)
        end
        row = row + 1
        local token_list = Util.SplitToken(line_content, "\t")
        if row == -1 then
            title_list = token_list
        elseif row == 0 then
            for i, title in ipairs(title_list) do
                value_type_list[title] = token_list[i]
            end
        else
            parse_result[row] = {}
            for i, v in ipairs(token_list) do
                local title_name = title_list[i]
                local value_type = value_type_list[title_name]
                assert(value_type)
                local save_func = SAVE_TITLE_FUNC_LIST[value_type]
                if save_func then
                    local item = TableParser.Parse(value_type, v, parse_result[row], row, parse_result, gen_env_func)
                    save_func(parse_result[row], title_name, item)
                end
            end
        end
    end

    Util.LoadFile(file_path,
        function(str_content)
            local line_list = Util.SplitToken(str_content, "\n")
            for _, line_content in ipairs(line_list) do
                local len = #line_content
                if line_content:sub(len, len) == "\r" then
                    line_content = line_content:sub(1, len - 1)
                end
                parseLine(line_content)
            end
        end
    )
    return parse_result
end

local function GeneratorConfigLua(tb)
    if not tb then
        return
    end
    return "return " .. Util.Table2OrderStr(tb)
end

local function GeneratorConfigTable(tb)
    if not tb then
        return
    end
    local order_row_list = {}
    for k, v in pairs(tb) do
        table.insert(order_row_list, k)
    end
    table.sort(order_row_list, function(a, b) return a < b end)

    local str_content = ""
    str_content = "id"
    local value_1 = tb[order_row_list[1]]

    local order_col_list = {}
    for k, v in pairs(value_1) do
        table.insert(order_col_list, k)
    end

    table.sort(order_col_list, function(a, b) return a < b end)
    for _, k in ipairs(order_col_list) do
        str_content = str_content .. "\t" .. tostring(k)
    end
    str_content = str_content .. "\n"

    for _, id in ipairs(order_row_list) do
        str_content = str_content .. tostring(id)
        local value_list = tb[id]
        for _, value_name in ipairs(order_col_list) do
            local value = value_list[value_name]
            if type(value) == "table" then
                if value.CalcValue then
                    str_content = str_content .. "\t" .. value.__class_name
                else
                    str_content = str_content .. "\t" .. Util.Table2Str(value)
                end
            else
                str_content = str_content .. "\t" .. tostring(value)
            end
        end
        str_content = str_content .. "\n"
    end
    str_content = str_content .. "\n"

    if IS_ENCODE == 1 then
        str_content = Encode(str_content)
    end
    return str_content
end


local CONFIG_LOADER = {
    ["lua"] = LoadConfigLua,
    ["table"] = LoadConfigTable,
}

local CONFIG_GENERATOR = {
    ["lua"] = GeneratorConfigLua,
    ["table"] = GeneratorConfigTable,
}

if not G_ConfigLoader then
    G_ConfigLoader = {}
end
local ConfigLoader = G_ConfigLoader
function ConfigLoader.LoadConfigFile(file_path, config_type, ...)
    if not config_type then
        config_type = "lua"
    end
    local load_func = CONFIG_LOADER[config_type]
    if not load_func then
        assert(false, "No Config[%s] Loader!!", config_type)
        return
    end
    return load_func(file_path, ...)
end

function ConfigLoader.GetGenerator(config_type)
    local func = CONFIG_GENERATOR[config_type]
    if not func then
        assert(false, "No Config[%s] Generator!!", config_type)
        return
    end
    return func
end

function ConfigLoader.GenerateConfig(tb, config_type, ...)
    local func = ConfigLoader.GetGenerator(config_type)
    if not func then
        return
    end
    local str_content = func(tb, ...)
    return str_content
end

--Unit Test
if arg and arg[1] == "config_loader.bytes" then
    function TestParse()
        local tb = ConfigLoader.LoadConfigFile("./setting/test_segment.txt", "table")
        local t = os.clock()
        for i = 1, 10000 do
            tb[1].test_1:Eval({value = 1, print = print})
        end
        print(os.clock() - t)

        local function Test(value)
            for i = 1, 100 do
                value = value + 1
            end
        end
        local test_2_tb = tb[1].test_2
        tb[1].test_2 = function()
            Test(test_2_tb[2])
        end
        local t = os.clock()
        for i = 1, 10000 do
            tb[1].test_2()
        end
        print(os.clock() - t)
    end
    TestParse()
end

return ConfigLoader
