local _, MB = ...

local ZoneElement = {}
MB.elements.zone = ZoneElement

local function formatZone(layoutMode)
    local zone = GetRealZoneText() or GetZoneText() or "Unknown"
    local subZone = GetSubZoneText() or ""
    if subZone ~= "" and subZone ~= zone then
        if layoutMode == "two_line" then
            return string.format("%s\n%s", zone, subZone)
        end
        return string.format("%s - %s", zone, subZone)
    end
    return zone
end

function ZoneElement:Create()
    local frame = MB.BaseElement:Create("zone", "Zone")

    function frame:Refresh()
        local config = MB.DB:GetElementConfig("zone")
        self:SetDisplayText(formatZone(config.zoneLayout))
    end

    local events = {
        "ZONE_CHANGED",
        "ZONE_CHANGED_NEW_AREA",
        "ZONE_CHANGED_INDOORS",
        "PLAYER_ENTERING_WORLD",
    }

    for _, eventName in ipairs(events) do
        MB.Events:Register(eventName, "ZONE_ELEMENT_" .. eventName, function()
            frame:Refresh()
        end)
    end

    frame:Refresh()
    return frame
end
