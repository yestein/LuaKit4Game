--=======================================================================
-- File Name    : maze_generator_2.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 31/05/2016 11:48:35
-- Description  : description
-- Modify       :
--=======================================================================

local Util = require "lib.util"

local WALL = 0
local CORRIDOR = 1

local END_FLAG = 9
local UNVISIT_ROOM = 10
local VISIT_ROOM = 11
local START_ROOM = 12
local TARGET_ROOM = 13


local ICON = {
    [WALL] = '###',
    [CORRIDOR] = ' . ',
    [START_ROOM] = ' S ',
    [TARGET_ROOM] = ' T ',
}

local function XY2Index(x, y)
    return x * 100 + y
end

local function Index2XY(index)
    return math.floor(index / 100), index % 100
end

local function PrintMap(data)
    for y, row in ipairs(data) do
        local str = ''
        for x, flag in ipairs(row) do
            str = str .. (ICON[flag] or " O ")
        end
        print(str)
    end
end

local count = 20
local function FillRect(x, y)
    local maze_data = {
        x = x,
        y = y,
    }
    for j = 1, 2 * y + 1 do
        maze_data[j] = {}
        for i = 1, 2 * x + 1 do
            if i % 2 == 0 and j % 2 == 0 then
                count = count + 1
                maze_data[j][i] = count
            else
                maze_data[j][i] = WALL
            end
        end
    end
    return maze_data
end

local function CanBreak(flag_a, flag_b)
    if flag_a == flag_b then
        return false
    end
    if math.random(100) > 50 then
        return false
    end
    return true
end

local function GetRowHandler(maze_data, max_x, max_y, judge_break_func)
    local set_list = {}
    local function GetSet(index)
        return set_list[index]
    end

    local function CreateSet(index)
        local set = Util.GetUnionSet()
        set.index = index
        set_list[index] = set
        return set
    end

    local function RemoveSet(index)
        set_list[index] = nil
    end

    local function GetRoomFlag(room_x, room_y)
        return maze_data[2 * room_y][2 * room_x]
    end

    local function SetRoomFlag(room_x, room_y, flag)
        maze_data[2 * room_y][2 * room_x] = flag
    end

    local function Break(room_x_a, room_y_a, room_x_b, room_y_b)
        maze_data[room_y_a + room_y_b][room_x_a + room_x_b] = CORRIDOR

        local flag_a = GetRoomFlag(room_x_a, room_y_a)
        local flag_b = GetRoomFlag(room_x_b, room_y_b)
        local set_a = GetSet(flag_a)
        local set_b = GetSet(flag_b)
        if set_b then
            set_b.ForEach(function(index)
                local x, y = Index2XY(index)
                SetRoomFlag(x, y, flag_a)
                set_a.Add(index)
            end)
            RemoveSet(flag_b)
        else
            SetRoomFlag(room_x_b, room_y_b, flag_a)
            set_a.Add(XY2Index(room_x_b, room_y_b))
        end
    end

    local function IsBreak(room_y, flag_a, flag_b)
        return judge_break_func(flag_a, flag_b) or (room_y == max_y and flag_a ~= flag_b)
    end

    return function(room_y)
        local temp_set_list = {}
        for room_x = 1, max_x do
            local flag_a = GetRoomFlag(room_x, room_y)
            local set = GetSet(flag_a)
            if not set then
                set = CreateSet(flag_a)
                set.Add(XY2Index(room_x, room_y))
            end
            local temp_set = temp_set_list[flag_a]
            if not temp_set then
                temp_set = Util.GetUnionSet()
                temp_set_list[flag_a] = temp_set
            end
            temp_set.Add(XY2Index(room_x, room_y))

            if room_x == max_x then
                break
            end

            --Break
            local flag_b = GetRoomFlag(room_x + 1, room_y)
            local is_break = IsBreak(room_y, flag_a, flag_b)
            if is_break then
                Break(room_x, room_y, room_x + 1, room_y)
            end
        end

        if room_y == max_y then
            return
        end

        --Down Break
        for index, set in pairs(temp_set_list) do
            local count = math.random(1, set.Count())
            local pick_list = Util.RandomPick(count, set._GetArray())
            for _, index in ipairs(pick_list) do
                local room_x, room_y = Index2XY(index)
                Break(room_x, room_y, room_x, room_y + 1)
            end
        end
    end
end

local function EllerGen(max_x, max_y)
    local maze_data = FillRect(max_x, max_y)
    local row_handler = GetRowHandler(maze_data, max_x, max_y, CanBreak)
    for room_y = 1, max_y do
        row_handler(room_y)
    end
    --Random Pick Start and Target
    local start_x, start_y = 1, 1
    maze_data[2 * start_y][2 * start_x] = START_ROOM
    local target_x, target_y = math.random(max_x // 2, max_x), math.random(max_y // 2, max_y)
    maze_data[2 * target_y][2 * target_x] = TARGET_ROOM
    return maze_data
end

--Unit Test
if arg and arg[1] == "maze_generator_eller.bytes" then
    math.randomseed(os.time())
    PrintMap(EllerGen(9, 7))
end

return EllerGen
