--=======================================================================
-- File Name    : framework.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/11/27 10:19:27
-- Description  : description
-- Modify       :
--=======================================================================

local function createFrameMode(logic_fps_, logic_func, exit_func)
    local logic_fps = logic_fps_
    local logic_frame_interval = 1 / logic_fps

    local logic_frame = 0

    local last_logic_clock

    local exit_flag = false
    local function exit()
        exit_flag = true
        if exit_func then
            exit_func(logic_frame)
        end
        return 1
    end

    local function loop(call_back)
        if exit_flag then
            return
        end
        local current_clock = os.clock()
        if not last_logic_clock then
            last_logic_clock = current_clock
        end
        if logic_func then
            if current_clock - last_logic_clock > logic_frame_interval then
                logic_frame = logic_frame + 1
                last_logic_clock = last_logic_clock + logic_frame_interval
                logic_func(logic_frame)
            end
        end
        if call_back then
            call_back()
        end
    end

    local function run(call_back)
        while not exit_flag do
            loop(call_back)
        end
        return 0
    end
    return {
        GetFps = function() return logic_fps end,
        GetLogicFrame = function() return logic_frame end,
        Run = run,
        Loop = loop,
        Exit = exit,
    }
end

local function create(type_, ...)
    if type_ == "frame" then
        return createFrameMode(...)
    end
end

--Unit Test
if arg and arg[1] == "framework_helper" then
    local logic_fps = 20
    local function logic(frame)
        print(frame)
        if frame % logic_fps == 0 then
            print(frame)
        end
    end

    local framework = createFrameMode(logic_fps, logic)
    framework.Run()
end

return {
    create = create,
}
