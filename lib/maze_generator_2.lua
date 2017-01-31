--=======================================================================
-- File Name    : maze_generator_2.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 31/05/2016 11:48:35
-- Description  : description
-- Modify       :
--=======================================================================

local Util = require "lib.util"

local DIRECTION = {
    {0, -1},
    {0, 1},
    {-1, 0},
    {1, 0},
}

local WALL = 0
local CORRIDOR = 1

local END_FLAG = 9
local UNVISIT_ROOM = 10
local VISIT_ROOM = 11
local START_ROOM = 12
local END_ROOM = 13


local ICON = {
    [WALL] = '#',
    [CORRIDOR] = '.',
    [UNVISIT_ROOM] = 'X',
    [VISIT_ROOM] = 'O',
    [START_ROOM] = 'S',
    [END_ROOM] = 'E',
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
            str = str .. ICON[flag]
        end
        print(str)
    end
end


local function FillRect(x, y)
    local maze_data = {
        x = x,
        y = y,
    }
    for j = 1, 2 * y + 1 do
        maze_data[j] = {}
        for i = 1, 2 * x + 1 do
            if i % 2 == 0 and j % 2 == 0 then
                maze_data[j][i] = UNVISIT_ROOM
            else
                maze_data[j][i] = WALL
            end
        end
    end
    return maze_data
end

local function VisitRoom(maze_data, x, y, flag)
    maze_data[y * 2][x * 2] = flag
end

local function IsRoomVisit(maze_data, x, y)
    return maze_data[y * 2][x * 2] > UNVISIT_ROOM
end

local function IsRoomEnd(maze_data, x, y)
    return maze_data[y * 2][x * 2] == END_FLAG
end

local function IsRoomValid(maze_data, x, y)
    return x > 0 and x <= maze_data.x and y > 0 and y <= maze_data.y
end

local function IsWallValid(maze_data, x, y)
    return x > 1 and x < 2 * maze_data.x + 1 and y > 1 and y < 2 * maze_data.y + 1
end

local function RandomPickCell(x, y)
    return math.random(1, x), math.random(1, y)
end

local function TryBreakWall(maze_data, x, y)
    local direction_copy = Util.CopyTB1(DIRECTION)
    local ret_x, ret_y
    repeat
        local direction_index = math.random(1, #direction_copy)
        local offset = direction_copy[direction_index]
        table.remove(direction_copy, direction_index)
        local map_x, map_y = 2 * x + offset[1], 2 * y + offset[2]
        local room_x, room_y = x + offset[1], y + offset[2]
        if IsRoomValid(maze_data, room_x, room_y) and not IsRoomVisit(maze_data, room_x, room_y) then
        -- if IsWallValid(maze_data, map_x, map_y) and maze_data[map_y][map_x] == WALL then
            maze_data[map_y][map_x] = CORRIDOR
            ret_x, ret_y = room_x, room_y
        end
        until ret_x or #direction_copy == 0

    return ret_x, ret_y
end

local function Break(maze_data, x, y, new_x, new_y)
    maze_data[new_y + y][x + new_x] = CORRIDOR
end

--Unit Test
if arg and arg[1] == "maze_generator_2.bytes" then
    math.randomseed(os.time())
    local maze_data = FillRect(7, 5)
    local end_x, end_y = RandomPickCell(7, 5)
    VisitRoom(maze_data, end_x, end_y, END_FLAG)
    local start_x, start_y = RandomPickCell(7, 5)
    local visit_room_set = Util.GetUnionSet()
    visit_room_set.Add(XY2Index(start_x, start_y))
    VisitRoom(maze_data, start_x, start_y, START_ROOM)
    while not visit_room_set.IsEmpty() do
        local new_index = visit_room_set.Random()
        local cur_x, cur_y = Index2XY(new_index)
        repeat
            local new_x, new_y = TryBreakWall(maze_data, cur_x, cur_y)
            if new_x and new_y then
                cur_x, cur_y = new_x, new_y
                if IsRoomEnd(maze_data, new_x, new_y) then
                    VisitRoom(maze_data, cur_x, cur_y, END_ROOM)
                    break
                else
                    VisitRoom(maze_data, cur_x, cur_y, VISIT_ROOM)
                    visit_room_set.Add(XY2Index(cur_x, cur_y))
                end
            end
            until not new_x and not new_y
        visit_room_set.Remove(XY2Index(cur_x, cur_y))
    end

    PrintMap(maze_data)
end

return {

}
