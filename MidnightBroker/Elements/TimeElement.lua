local _, MB = ...

local TimeElement = {}
MB.elements.time = TimeElement

local function buildDateTimeText(config)
    local dateText = date(config.dateFormat or "%Y-%m-%d")
    local timeText = date(config.timeFormat or "%H:%M:%S")
    local layout = config.dateTimeLayout or "date_then_time"

    if layout == "time_then_date" then
        return string.format("%s %s", timeText, dateText)
    elseif layout == "two_line" then
        return string.format("%s\n%s", dateText, timeText)
    end

    return string.format("%s %s", dateText, timeText)
end

function TimeElement:Create()
    local frame = MB.BaseElement:Create("time", "Date-Time")

    function frame:Refresh()
        local config = MB.DB:GetElementConfig("time")
        self:SetDisplayText(buildDateTimeText(config))
    end

    MB.Throttle:Register("TIME_ELEMENT", MB.Constants.UPDATE_INTERVALS.TIME, function()
        frame:Refresh()
    end)

    frame:Refresh()
    return frame
end
