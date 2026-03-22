local _, MB = ...

local LatencyElement = {}
MB.elements.latency = LatencyElement

local function getLatencyValues()
    local _, _, home, world = GetNetStats()
    return home, world
end

local function getLatencyText()
    local home, world = getLatencyValues()
    if not home or not world then
        return "--/-- ms"
    end
    return string.format("%d/%d ms", home, world)
end

function LatencyElement:Create()
    local frame = MB.BaseElement:Create("latency", "Latency")

    function frame:Refresh()
        self:SetDisplayText(getLatencyText())
    end

    MB.Throttle:Register("LATENCY_ELEMENT", MB.Constants.UPDATE_INTERVALS.LATENCY, function()
        frame:Refresh()
    end)

    function frame:OnHoverEnter()
        local home, world = getLatencyValues()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Latency Details")
        if not home or not world then
            GameTooltip:AddLine("Unavailable", 0.8, 0.8, 0.8)
        else
            GameTooltip:AddDoubleLine("Home", string.format("%d ms", home), 0.85, 0.85, 0.85, 1, 1, 1)
            GameTooltip:AddDoubleLine("World", string.format("%d ms", world), 0.85, 0.85, 0.85, 1, 1, 1)
        end
        GameTooltip:Show()
    end

    function frame:OnHoverLeave()
        GameTooltip:Hide()
    end

    frame:Refresh()
    return frame
end
