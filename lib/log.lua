--=======================================================================
-- File Name    : log.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 15:43:46
-- Description  : log system
-- Modify       :
--=======================================================================

if not G_Log then
    G_Log = {}
end

local Log = G_Log

Log.LOG_DEBUG   = 1
Log.LOG_INFO    = 2
Log.LOG_WARNING = 3
Log.LOG_ERROR   = 4

local LOG_TEXT = {
    [Log.LOG_DEBUG  ] = "DEBUG",
    [Log.LOG_INFO   ] = "INFO ",
    [Log.LOG_WARNING] = "WARN ",
    [Log.LOG_ERROR  ] = "ERROR",
}

function Log:Init(folder_path, log_level, view_level, prefix)
    self.folder_path = folder_path
    self.log_level = log_level or Log.LOG_DEBUG
    self.view_level = view_level or Log.LOG_INFO

    local log_path = self:GetLogFileByTime(prefix or "log")
    self.fp = io.open(folder_path .. "/" .. log_path, "w")
    if not self.fp then
        assert(false)
        return 0
    end
    return 1
end

function Log:GetLogFileByTime(prefix)
    local t = os.date("*t",time)
    local file_name = string.format("%s_%d_%02d_%02d_%02d_%02d_%02d.log", prefix, t.year, t.month, t.day, t.hour, t.min, t.sec)
    return file_name
end

function Log:CheckLevel(log_level)
    if log_level > self.LOG_ERROR then
        log_level = self.LOG_ERROR
    elseif log_level < self.LOG_DEBUG then
        log_level = self.LOG_DEBUG
    end
    return log_level
end

function Log:SetLogLevel(log_level)
    self.log_level = self:CheckLevel(log_level)
end

function Log:SetViewLevel(view_level)
    self.view_level = Log:CheckLevel(view_level)
end

function Log:ParseText(fmt, ...)
    if not fmt then
        return ""
    end
    local result, text = pcall(string.format, fmt, ...)
    if not result then
        return fmt .. Util.TransArgs2Str(...)
    end
    return text
end

function Log:Print(log_level, fmt, ...)
    local text = self:ParseText(fmt, ...)
    if self.log_level and log_level >= self.log_level then
        self:WriteLog(log_level, text)
    end
    if not self.view_level or log_level >= self.view_level then
        print(text)
    end
    return text
end

function Log:WriteLog(log_level, text)
    if not self.fp then
        return
    end
    local time_text = os.date("%Y-%m-%d %H:%M:%S")
    local content = string.format("[%s][%s] %s",
        LOG_TEXT[log_level] or tostring(log_level),
        time_text, text)
    self.fp:write(content.."\n")
    self.fp:flush()
end

--Unit Test
if arg and arg[1] == "log" then
    Log:Init("./log", Log.LOG_DEBUG, Log.LOG_INFO)
    Log:Print(Log.LOG_DEBUG, "test log")
    Log:Print(Log.LOG_INFO, "test view")
end

return Log
