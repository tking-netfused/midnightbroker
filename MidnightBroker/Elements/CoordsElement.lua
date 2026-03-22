local _, MB = ...

local CoordsElement = {}
MB.elements.coords = CoordsElement

local function getCoordsText()
    -- Assumption: Retail C_Map APIs are available in this client build.
    local mapId = C_Map.GetBestMapForUnit("player")
    if not mapId then
        return "--.--, --.--"
    end

    local position = C_Map.GetPlayerMapPosition(mapId, "player")
    if not position then
        return "--.--, --.--"
    end

    return string.format("%.2f, %.2f", position.x * 100, position.y * 100)
end

function CoordsElement:Create()
    local frame = MB.BaseElement:Create("coords", "Coords")

    function frame:Refresh()
        self:SetDisplayText(getCoordsText())
    end

    MB.Events:Register("PLAYER_ENTERING_WORLD", "COORDS_ELEMENT_WORLD", function()
        frame:Refresh()
    end)

    MB.Throttle:Register("COORDS_ELEMENT", MB.Constants.UPDATE_INTERVALS.COORDS, function()
        frame:Refresh()
    end)

    frame:Refresh()
    return frame
end
