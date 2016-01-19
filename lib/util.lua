--=======================================================================
-- File Name    : util.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/11/24 18:41:55
-- Description  : common function
-- Modify       :
--=======================================================================

local assert = require("lib.assert")

local Util = {}

function Util.SafeCall(callback, ...)
    if not callback then
        return
    end
    local function traceBack(s)
        print(debug.traceback(s, 2))
    end
    local callback_type = type(callback)
    if callback_type == "table" then
        local tb = {}
        for i = 2 , #callback do
            tb[#tb + 1] = callback[i]
        end
        local args = {...}
        for i = 1, #args do
            tb[#tb + 1] = args[i]
        end
        return xpcall(callback[1], traceBack, table.unpack(tb))
    elseif callback_type == "function" then
        return xpcall(callback, traceBack, ...)
    else
        assert(false)
    end
end

function Util.CopyTB1(tb)
    local ret = {}
    for k, v in pairs(tb) do
        ret[k] = v
    end
    return ret
end

function Util.Show2DTB(tb, row, column, is_reverse)
    local title = "\t"
    if is_reverse ~= 1 then
        for i = 1, column do
            title = title.."\t"..i
        end
        print(title)
        print("-----------------------------------------------------------------------------------------------")
        for i = 1, row do
            local msg = i.."\t|"
            if tb[row] then
                for j = 1, column do
                    msg = msg .."\t"..tostring(tb[i][j])
                end
                print(msg)
            end
        end
    else
        for i = 1, row do
            title = title.."\t"..i
        end
        print(title)
        print("-----------------------------------------------------------------------------------------------")
        for i = 1, column do
            local msg = i.."\t|"
            if tb[column] then
                for j = 1, row do
                    msg = msg .."\t"..tostring(tb[j][i])
                end
                print(msg)
            end
        end
    end
end

function Util.CopyTo(src_table, dest_table)
    if type(src_table) == "table" and type(dest_table) == "table" then
        for k, v in pairs(src_table) do
            if type(v) == "table" and type(dest_table[k]) == "table" then
                self:CopyTo(v, dest_table[k])
            else
                dest_table[k] = v
            end
        end
    else
        assert(false, "Type Error! src[%s] dest[%s]", type(src_table), type(dest_table))
    end
end

function Util.CopyTB1(tb)
    if not tb then
        assert(false, "the copy table is nil")
        return
    end
    local table_copy = {}
    for k, v in pairs(tb) do
        table_copy[k] = v
    end
    return table_copy
end

function Util.CopyTB(tb, max_depth)
    if not tb then
        assert(false, "the copy table is nil")
        return
    end
    if not max_depth then
        max_depth = 1
    end
    local table_copy = {}
    local function CopyTB(table, table_copy, depth)
        if depth > max_depth then
            return
        end
        for k, v in pairs(table) do
            if type(v) ~= "table" then
                table_copy[k] = v
            else
                table_copy[k] = {}
                CopyTB(v, table_copy[k], depth + 1)
            end
        end
    end
    CopyTB(tb, table_copy, 1)
    return table_copy
end

function Util.Copy2DTB(tb)
    if not tb then
        assert(false, "the copy 2d table is nil")
        return
    end
    local table_copy = {}
    for i, row in pairs(tb) do
        table_copy[i] = {}
        for j, v in pairs(row) do
            table_copy[i][j] = v
        end
    end
    return table_copy
end

function Util.CountTB(tb)
    if not tb then
        print("the count table is nil")
        return 0
    end
    local count = 0
    for k, v in pairs(tb) do
        count = count + 1
    end
    return count
end

function Util.GetFormatTime(time)
    return string.format("%02d:%02d:%02d", math.floor(time / 3600), math.floor(time / 60) % 60, time % 60)
end

function Util.ConcatArray(array_dest, array_src)
    for _, v in ipairs(array_src) do
        array_dest[#array_dest + 1] = v
    end
end

function Util.MergeTable(table_dest, table_src)
    if not table_src then
        return table_dest
    end
    for k, v in pairs(table_src) do
        if type(table_dest[k]) == "number" and type(v) == "number" then
            table_dest[k] = table_dest[k] + v
        else
            table_dest[k] = v
        end
    end
end

function Util.ShowTB(target_table, max_depth, depth)
    if not target_table then
        print("nil")
        return
    end
    if not max_depth then
        max_depth = 2
    end
    if not depth then
        depth = 1
    end

    if depth == 1 then
        print("= {")
    end

    local content = nil
    local str_blank = string.rep("  ", depth)

    if depth > max_depth then
        print(str_blank .. "...")
        return
    end
    for k, v in pairs(target_table) do
        if type(v) ~= "table" then
            print(string.format("%s[%s] = %s", str_blank, tostring(k), tostring(v)))
        else
            print(string.format("%s[%s] = {", str_blank, tostring(k)))
            Util.ShowTB(v, max_depth, depth + 1)
            print(string.format("%s}", str_blank))
        end
    end
    if depth == 1 then
        print("}")
    end
end

function Util.GetDistanceSquare(x1, y1, x2, y2)

    local distance_x = x1 - x2
    local distance_y = y1 - y2

    return (distance_y * distance_y) + (distance_x * distance_x)
end

function Util.GetDistance(x1, y1, x2, y2)

    local distance_x = x1 - x2
    local distance_y = y1 - y2

    return math.sqrt((distance_y * distance_y) + (distance_x * distance_x))
end

function Util.GetDiamondPosition(row, column, cell_width, cell_height, start_x, start_y)
    local x, y = self:_GetDiamondPosition(row, column, cell_width, cell_height)
    local position_x = start_x + x * cell_width
    local position_y = start_y + y * cell_height

    return position_x, position_y
end

function Util._GetDiamondPosition(row, column)
    local x = (column - row) / 2
    local y = (1 - row - column) / 2
    return x, y
end

function Util.GetDiamondLogicPosition(x, y, cell_width, cell_height, start_x, start_y)
    local row = math.ceil((start_x - x) / cell_width + (start_y - y) / cell_height)
    local column = math.ceil((x - start_x) / cell_width - (y - start_y) / cell_height)

    return row, column
end


function Util.GetTableOrderedKeyList(tb)
    local list = {}
    for key, value in pairs(tb) do
        table.insert(list, key)
    end
    table.sort(list)
    return list
end


local function Sort(tb)
    local number_list = {}
    local hash_list = {}
    for k, v in pairs(tb) do
        if type(k) == "number" then
            table.insert(number_list, k)
        elseif type(k) == "string" then
            table.insert(hash_list, k)
        else
            assert(false)
        end
    end
    local function cmp(a, b) return a < b end
    table.sort(number_list, cmp)
    table.sort(hash_list, cmp)

    Util.ConcatArray(hash_list, number_list)

    return hash_list
end

local function LineFormat(depth, str_content)
    if str_content == "}" then
        return string.rep("  ", depth) ..  str_content
    else
        return string.rep("  ", depth) ..  str_content .. "\n"
    end
end

function Util.Table2Str(raw_tb, sort_func, line_format_func)
    local function TransTable2Str(tb, depth)
        local line_list = {}
        line_list[#line_list + 1] = line_format_func and line_format_func(0, "{") or "{"

        local function translate2Str(k, v)
            local key_str = nil
            local type_key = type(k)
            if type_key == "number" then
                key_str = string.format("[%d]=", k)
            elseif type_key == "string" then
                key_str = string.format("[%q]=", k)
            else
                assert(false)
                return
            end

            local value_str = nil
            local type_value = type(v)
            if type_value == "table" then
                value_str = TransTable2Str(v, depth + 1) .. ","
            elseif type_value == "string" then
                value_str = string.format("%q,", v)
            elseif type_value == "number" then
                value_str = string.format("%d,", v)
            else
                assert(false)
                return
            end

            local content = key_str .. value_str
            if line_format_func then
                content = line_format_func(depth, content)
            end
            return content
        end

        if sort_func then
            for _, k in pairs(sort_func(tb)) do
                line_list[#line_list + 1] = translate2Str(k, tb[k])
            end
        else
            for k, v in pairs(tb) do
                line_list[#line_list + 1] = translate2Str(k, v)
            end
        end
        line_list[#line_list + 1] = line_format_func and line_format_func(depth - 1, "}") or "}"
        return table.concat(line_list)
    end
    return TransTable2Str(raw_tb, 1)
end

function Util.Table2OrderStr(raw_tb)
    return Util.Table2Str(raw_tb, Sort, LineFormat)
end

function Util.Str2Val(str, env)
    if env then
        return assert(load("return ".. str, "Str2Val Temp", "bt", env), str)()
    else
        return assert(load("return ".. str), str)()
    end
end

function Util.SaveFile(file_path, content)
    local result = 0
    local file = io.open(file_path, "w")
    if not file then
        goto Exit0
    end
    file:write(content)
    file:close()
    result = 1
::Exit0::
    return result
end

function Util.LoadFile(file_path, callback)
    local file = io.open(file_path, "r")
    if not file then
        print("can't find ", file_path)
        return
    end
    local content = file:read("a")
    file:close()
    Util.SafeCall(callback, content)
    return content
end

function Util.GetReadOnly(tb)
    local tb_read_only = {}
    local mt = {
        __index = tb,
        __newindex = function(tb, key, value)
            assert(false, "Error!Attempt to update a read-only table!!")
        end
    }
    setmetatable(tb_read_only, mt)
    return tb_read_only
end

local TIME_AREA = {
    ["Beijing"] = 8 * 3600,
}
function Util.GetWorldTime(area)
    if not area then
        area = "Beijing"
    end
    assert(TIME_AREA[area])
    local seconds = os.time()
    return seconds + TIME_AREA[area]
end

function Util.IsIntersects(x_1, y_1, width_1, height_1, x_2, y_2, width_2, height_2)
    local min_x_1 = x_1
    local max_x_1 = x_1 + width_1
    local min_y_1 = y_1
    local max_y_1 = y_1 + height_2

    local min_x_2 = x_2
    local max_x_2 = x_2 + width_2
    local min_y_2 = y_2
    local max_y_2 = y_2 + height_2

    if (max_x_1 < min_x_2) or (max_x_2 < min_x_1)
     or (max_y_1 < min_y_2) or (max_y_2 < min_y_1) then
         return 0
    end

    return 1
end

function Util.GetAngle(raw_angle, x_1, y_1, x_2, y_2)
    local delta_x = x_2 - x_1
    local delta_y = y_2 - y_1

    if delta_x == 0 and delta_y >= 0 then
        angle = 0
    elseif delta_x > 0 and delta_y > 0 then
        angle = math.deg(math.atan(delta_x / delta_y))
    elseif delta_x > 0 and delta_y == 0 then
        angle = 90
    elseif delta_x > 0 and delta_y < 0 then
        angle = 180 + math.deg(math.atan(delta_x / delta_y))
    elseif delta_x == 0 and delta_y < 0 then
        angle = 180
    elseif delta_x < 0 and delta_y < 0 then
        angle = 180 + math.deg(math.atan(delta_x / delta_y))
    elseif delta_x < 0 and delta_y == 0 then
        angle = 270
    elseif delta_x < 0 and delta_y > 0 then
        angle = 360 + math.deg(math.atan(delta_x / delta_y))
    end

    return angle - raw_angle
end

function Util.Dijkstra(map, start_node, end_node)
    local node_info_list = {[start_node] = {value = 0, path = {}},}
    local U = {}
    for k, v in pairs(map) do
        if k ~= start_node then
            U[k] = 1
        end
    end
    local current_node = start_node
    local current_node_info = node_info_list[start_node]
    while Util.CountTB(U) > 0 do
        local min_value = nil
        local nearest_node = nil
        for search_node, _ in pairs(U) do
            local value = map[current_node] and map[current_node][search_node] or nil
            if value then
                if not min_value or min_value > value then
                    min_value = value
                    nearest_node = search_node
                end
                local path = Util.CopyTB1(current_node_info.path)
                table.insert(path, current_node)

                local search_node_info = node_info_list[search_node]
                if not search_node_info then
                    node_info_list[search_node] = {
                        value = current_node_info.value + value,
                        path = path,
                    }
                else
                    if current_node_info.value + value < search_node_info.value then
                        search_node_info.value = current_node_info.value + value
                        search_node_info.path = path
                    end
                end
            end
        end
        U[current_node] = nil
        for search_node, _ in pairs(U) do
            if node_info_list[search_node] then
                current_node = search_node
                current_node_info = node_info_list[search_node]
                break
            end
        end
    end
    return node_info_list
end

function Util.Equal(a, b)
    if type(a) ~= type(b) then
        return false
    end
    local element_type = type(a)
    if element_type == "number" then
        if math.abs(a - b) < 0.001 then
            return true
        end
    else
        return a == b
    end
end

function Util.CompareTB(tb_a, tb_b)
    local count_a = Util.CountTB(tb_a)
    local count_b = Util.CountTB(tb_b)
    if count_a ~= count_b then
        print("count diff", count_a, count_b)
        return 0
    end
    for k, v in pairs(tb_a) do
        local type_a = type(v)
        local type_b = type(tb_b[k])
        if type_a ~= type_b then
            print(k, "type diff", type_a, type_b)
            return 0
        end
        if type_a == "table" then
            if Util.CompareTB(v, tb_b[k]) ~= 1 then
                print(k, "table diff")
                return 0
            end
        else
            if v ~= tb_b[k] then
                print(k, "value diff", v, tb_b[k])
                return 0
            end
        end
    end
    return 1
end

function Util.SplitToken(str, seperate_str)
    local token_list = {}
    local str_len = #str
    local seperate_str_len = #seperate_str
    local begin_index = 1
    local end_index

    end_index = str:find(seperate_str, begin_index, true)
    while end_index do
        table.insert(token_list, str:sub(begin_index, end_index - 1))
        begin_index = end_index + seperate_str_len
        end_index = str:find(seperate_str, begin_index, true)
    end
    if begin_index <= str_len then
        table.insert(token_list, str:sub(begin_index))
    elseif begin_index == str_len + seperate_str_len then
        table.insert(token_list, "")
    end
    return token_list
end

function Util.GetAccumulator(start_index, max_index)
    local index = start_index - 1
    return function()
        if max_index and index >= max_index then
            assert(false, "枚举值已超出最大值%d", max_index)
        end
        index = index + 1
        return index
    end
end

function Util.TransArgs2Str(...)
    local str = ""
    local args = {...}
    local count = select("#", ...)
    for i = 1, count do
        str = str .. tostring(args[i])
        if i ~= count then
            str = str .. "|"
        end
    end
    return str
end


--Unit Test
if arg and arg[1] == "util" then
    local function test(...)
        print(...)
    end
    Util.SafeCall({test, 1, 2}, 3, 4)

    local connect_map = {
        pos_0 = {["pos_3"] = 1, ["pos_4"] = 1,},
        pos_1 = {["pos_8"] = 1,},
        pos_2 = {["pos_4"] = 1,},
        pos_3 = {["pos_0"] = 1, ["pos_7"] = 1,},
        pos_4 = {["pos_2"] = 1, ["pos_8"] = 1, ["pos_0"] = 1, ["pos_7"] = 1,},
        pos_5 = {["pos_7"] = 1,},
        pos_6 = {["pos_7"] = 1,},
        pos_7 = {["pos_3"] = 1, ["pos_4"] = 1, ["pos_5"] = 1, ["pos_6"] = 1,},
        pos_8 = {["pos_1"] = 1, ["pos_4"] = 1,},
    }

    local result = Util.Dijkstra(connect_map, "pos_3")
    Util.ShowTB(result, 3)

    --Test Str2Val

    local cmd1 = "function () for k, v in pairs(_ENV) do print(k, v) end  if a then for k, v in pairs(a) do print(k, v) end end end "
    local f1 = Util.Str2Val(cmd1)
    Util.SafeCall(f1)

    local env = {
        a = {1, 2, 3, 4},
        print = print,
        pairs = pairs,
        ipairs = ipairs,
        Util = Util,
    }
    local cmd2 = "function () Util.ShowTB(_ENV, 1) for k, v in pairs(a) do print(k, v) end end"
    local f2 = Util.Str2Val(cmd2, env)
    Util.SafeCall(f2)

    --Test Copy Table
    local src = {1, {2}, {{3}}}
    local dest = Util.CopyTB(src, 3)
    print(src, dest)
    Util.ShowTB(dest, 3)
    dest[3] = 2
    Util.ShowTB(src, 3)
    Util.ShowTB(dest, 3)

    --Test CompareTable
    local a = {2}
    local b = {1}
    local c = {b = {3, 4}, {{3}}, {"a"}, a = {4, 4}}
    local d = {{{3}}, {"a"}, a = {4, 4}, b = {3, 4},}
    local e = {a = {4, 4}, {"a"}, b = {3, 4}, {{3}},}
    print(Util.CompareTB(a, b))
    print(Util.CompareTB(b, a))
    print(Util.CompareTB(c, d))
    print(Util.CompareTB(d, c))
    print(Util.CompareTB(d, e))

    --Test Table2Str
    local test_table = {
        [1] = {
            ["1"] = {
                ["array"] = {
                    "1", 2, "a"
                },
                ["hash"] = { a = 1, b = "2"}
            },
        },
        ["1"] = "a",
        ["a"] = "a",
    }
    local str1 = Util.Table2Str(test_table)
    print(str1)
    local str2 = Util.Table2OrderStr(test_table)
    print(str2)
    print(Util.CompareTB(test_table, Util.Str2Val(str1)))
    print(Util.CompareTB(test_table, Util.Str2Val(str2)))

    local time
    function hook(p)
        local name = debug.getinfo(2, "n").name
        if name == "TestHook" or name == "ReloadScript" then
            if p == "call" then
                time = os.clock()
            end
            Util.ShowTB(debug.getinfo(2, "n"))
            Util.ShowTB(debug.getinfo(2, "S"))
            Util.ShowTB(debug.getinfo(2, "u"))
            Util.ShowTB(debug.getinfo(2, "t"))
            Util.ShowTB(debug.getinfo(2, "l"))

            if p == "return" then
                print("cost", os.clock() - time)
            end
            print(p, "Hooked!")
        end
    end

    local function TestHook()
        print(1)
        print(1)
        print(1)
        print(1)
        print(1)
    end

    local function TestHook1()
        Util.TestHook()
    end
end

return Util
