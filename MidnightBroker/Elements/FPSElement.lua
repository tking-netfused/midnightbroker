local _, MB = ...

local FPSElement = {}
MB.elements.fps = FPSElement

local function getFPSText()
    return string.format("%d FPS", math.floor((GetFramerate() or 0) + 0.5))
end

function FPSElement:Create()
    local frame = MB.BaseElement:Create("fps", "FPS")

    function frame:Refresh()
        self:SetDisplayText(getFPSText())
    end

    MB.Throttle:Register("FPS_ELEMENT", MB.Constants.UPDATE_INTERVALS.FPS, function()
        frame:Refresh()
    end)

    frame:Refresh()
    return frame
end
