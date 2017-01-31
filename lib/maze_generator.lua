--=======================================================================
-- File Name    : maze_generator.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 31/05/2016 11:48:35
-- Description  : description
-- Modify       :
--=======================================================================
local offset_list = {
    {1, 0, 65},
    {0, 1, 15},
    {0, -1, 15},
    {-1, 0, 5},
}
local function GetOffset(random_func, raw_list)
    return function()
        return random_func(raw_list)
    end
end

local function GetConnectFunc()
    return function(store_result, x1, y1, x2, y2)
        if not store_result[x1] then
            store_result[x1] = {}
        end
        if not store_result[x1][y1] then
            store_result[x1][y1] = {
                distance = 0,
                connect_list = {},
            }
        end
        if not x2 or not y2 then
            return
        end
        local start_info = store_result[x1][y1]

        if store_result[x2] and store_result[x2][y2] then
            return false
        end
        -- print(string.format("(%d, %d) -> (%d, %d)", x1, y1, x2, y2))
        table.insert(start_info.connect_list, {x2, y2})
        if not store_result[x2] then
            store_result[x2] = {}
        end
        store_result[x2][y2] = {
            distance = start_info.distance + 1,
            connect_list = {}
        }
        return true
    end
end

local function GetValid(max_x, max_y)
    return function(x, y)
        return x > 0 and x <= max_x and y > 0 and y <= max_y
    end
end

local function RandomWeightDirection(tb)
    local function MakeWeightTable(raw_weight_table)
        local sum = 0
        local result = {}
        for i, data in ipairs(raw_weight_table) do
            sum = sum + data[3]
            result[i] = sum
        end
        return result
    end
    local copy = Util.CopyTB1(tb)
    local result = {}
    repeat
        local weight_table = MakeWeightTable(copy)
        local r = math.random(1, weight_table[#weight_table])
        local pick_index = nil
        for i, weight in ipairs(weight_table) do
            if r < weight then
                pick_index = i
                break
            end
        end
        table.insert(result, copy[pick_index])
        table.remove(copy, pick_index)
        until
            #copy <= 0

    return result
end

local function GetNearIter(valid)
    return function(x, y, i, offset_list)
        if not i then
            i = 0
        end
        local index = i
        local near_x, near_y
        repeat
            index = index + 1
            local offset = offset_list[index]
            if not offset then
                return
            end
            near_x, near_y = x + offset[1], y + offset[2]
        until
            valid(near_x, near_y)

        return index, near_x, near_y
    end
end

local function GetGenerator(near_iter, offset_func, try_connect)
    local function GenearteWay(store_result, start_x, start_y, max_depth)
        local way = {}
        table.insert(way, {start_x, start_y})
        if max_depth <= 0 then
            return way
        end
        local near_index, near_x, near_y
        local offset_list = offset_func()
        try_connect(store_result, start_x, start_y)
        repeat
            near_index, near_x, near_y = near_iter(start_x, start_y, near_index, offset_list)
            if not near_x or not near_y then
                return way
            end
            local result = try_connect(store_result, start_x, start_y, near_x, near_y)
        until
            result
        -- print(string.format("[%d, %d]  --> [%d, %d]", start_x, start_y, near_x, near_y))
        local sub_way = GenearteWay(store_result, near_x, near_y, max_depth - 1, near_iter, offset_func, try_connect)
        if sub_way then
            table.insert(way, sub_way)
        end
        return way
    end
    return GenearteWay
end

local function GetNext(way)
    return way[1], way[2]
end

local function XY2Index(x, y)
    return x * 100 + y
end

local function Index2XY(index)
    return math.floor(index / 100), index % 100
end

local function RandomMazeByWay(start_x, start_y, max_x, max_y, main_way_length, normal_way_length, cell_count)
    local result = {
        start_x = start_x,
        start_y = start_y,
        max_x = max_x,
        max_y = max_y,
        leaf_list = Util.GetUnionSet(),
        cross_list = Util.GetUnionSet(),
        path_list = {},
        matrix = {},
    }
    local x, y = start_x, start_y
    local genertor = GetGenerator(GetNearIter(GetValid(max_x, max_y)), GetOffset(RandomWeightDirection, offset_list), GetConnectFunc())
    local union_set = Util.GetUnionSet()
    local way_length = math.min(main_way_length, cell_count)
    local raw_leaf_list = {}
    local loop = 100
    local remove_list = {}
    while loop > 0 do
        local way = genertor(result.matrix, x, y, way_length)
        local node_count = 0
        if way then
            local path = {}
            local node
            repeat
                node_count = node_count + 1
                node, way = GetNext(way)
                table.insert(path, node)
                local node_x, node_y = table.unpack(node)
                -- if #result.path_list == 0 then
                --     print(node_x, node_y)
                -- end
                local node_index = XY2Index(node_x, node_y)
                if union_set.Add(node_index) then
                    cell_count = cell_count - 1
                else
                    if #result.matrix[node_x][node_y].connect_list > 1 then
                        result.cross_list.Add(node_index)
                    end
                end
                until
                    not way
            table.insert(result.path_list, path)
            table.insert(raw_leaf_list, node)
            -- print(cell_count)
            if cell_count <= 0 then
                goto Exit0
            end
        end
        if node_count == 1 then
            remove_list[XY2Index(x, y)] = 1
            union_set.Remove(XY2Index(x, y))
        end
        local count = 0
        repeat
            count = count + 1
            x, y = Index2XY(union_set.Random())
            until (x ~= start_x or y ~= start_y) or (count > 10)
        assert(not remove_list[XY2Index(x, y)])
        way_length = math.random(1, math.min(normal_way_length, cell_count))
        loop = loop - 1
    end
    ::Exit0::
    -- print("loop", loop)
    for _, check_leaf in ipairs(raw_leaf_list) do
        local _x, _y = table.unpack(check_leaf)
        local info = result.matrix[_x][_y]
        if #info.connect_list <= 0 then
            result.leaf_list.Add(XY2Index(_x, _y))
        end
    end
    return result
end

--Unit Test
if arg and arg[1] == "maze_generator.bytes" then
    local Util = require("lib.util")
    math.randomseed(os.time())
    local width = 3
    local max_depth = 10
    local result = {}
    -- local genertor = GetGenerator(GetNearIter(GetValid(width, max_depth)), GetOffset(RandomWeightDirection, offset_list), GetConnectFunc())
    -- local way_1 = genertor(result, 1, width, max_depth)

    -- local node
    -- local next_way = way_1
    -- for i = 1, 2 do
    --     node, next_way = GetNext(next_way)
    --     -- print(table.unpack(node))
    -- end

    -- local way_2 = genertor(result, node[1], node[2], 5)

    -- local stat_result = {
    --     [XY2Index(0, 1)] = {0, 0, 0, 0},
    --     [XY2Index(0, -1)] = {0, 0, 0, 0},
    --     [XY2Index(1, 0)] = {0, 0, 0, 0},
    --     [XY2Index(-1, 0)] = {0, 0, 0, 0},
    -- }
    -- for loop = 1, 10000 do
    --     local new_list = RandomWeightDirection(offset_list)
    --     for i, data in ipairs(new_list) do
    --         stat_result[XY2Index(data[1], data[2])][i] = stat_result[XY2Index(data[1], data[2])][i] + 1
    --     end
    -- end

    -- Util.ShowTB(stat_result)

    local result = RandomMazeByWay(1, 1, 1, 1, 7, 3, 1)
    local tb_2d = {}
    for x, list in pairs(result.matrix) do
        tb_2d[x] = {}
        for y, _ in pairs(list) do
            tb_2d[x][y] = 1
        end
    end
    Util.Show2DTB(tb_2d, max_depth, width, 1)
end

return {
    RandomMazeByWay = RandomMazeByWay,
    XY2Index = XY2Index,
    Index2XY = Index2XY,
}
