--=======================================================================
-- File Name    : assert.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 15:40:16
-- Description  : replace lua assert
-- Modify       :
--=======================================================================
local Log = require("lib.log")

local function MyAssert(expression, fmt, ...)
    if not expression then
        fmt = "assertion failed!\t" .. (fmt or "")
        Log:Print(Log.LOG_ERROR, fmt, ...)
        local str_traceback = debug.traceback()
        Log:Print(Log.LOG_ERROR, str_traceback)
    end
    return expression
end

--Unit Test
if arg and arg[1] == "assert" then
    local a = 2
    MyAssert(a == 3, "a's value is %d", a)
    MyAssert(a == 2, "a's value is %d", a)
    MyAssert(a == 4, "a's value is %d", a)
end

return MyAssert
