local _, MB = ...

local CoordsElement = {}
MB.elements.coords = CoordsElement

local IDLE_UPDATE_INTERVAL = 0.25

local function clampDecimals(decimals)
    if type(decimals) ~= "number" then
        return 2
    end
    return math.max(0, math.min(2, math.floor(decimals + 0.5)))
end

local function roundTo(value, decimals)
    local factor = 10 ^ decimals
    return math.floor((value * factor) + 0.5) / factor
end

local function formatCoords(roundedX, roundedY, decimals)
    if decimals == 0 then
        return string.format("%.0f, %.0f", roundedX, roundedY)
    elseif decimals == 1 then
        return string.format("%.1f, %.1f", roundedX, roundedY)
    end
    return string.format("%.2f, %.2f", roundedX, roundedY)
end

local function getRoundedCoords(decimals)
    -- Assumption: Retail C_Map APIs are available in this client build.
    local mapId = C_Map.GetBestMapForUnit("player")
    if not mapId then
        return nil
    end

    local position = C_Map.GetPlayerMapPosition(mapId, "player")
    if not position then
        return nil
    end

    local rawX = position.x * 100
    local rawY = position.y * 100
    return mapId, roundTo(rawX, decimals), roundTo(rawY, decimals)
end

local function isPlayerInMotion()
    local speed = GetUnitSpeed("player") or 0
    if speed > 0 then
        return true
    end
    if UnitOnTaxi and UnitOnTaxi("player") then
        return true
    end
    if IsFlying and IsFlying() then
        return true
    end
    if IsFalling and IsFalling() then
        return true
    end
    return false
end

function CoordsElement:Create()
    local frame = MB.BaseElement:Create("coords", "Coords")
    frame.skipAutoResize = true
    frame.isMoving = false

    function frame:ApplyUpdateInterval()
        local config = MB.DB:GetElementConfig("coords")
        local movingInterval = config.coordsUpdateInterval or MB.Constants.UPDATE_INTERVALS.COORDS
        local targetInterval = self.isMoving and movingInterval or IDLE_UPDATE_INTERVAL
        if self.currentUpdateInterval ~= targetInterval then
            MB.Throttle:SetInterval("COORDS_ELEMENT", targetInterval)
            self.currentUpdateInterval = targetInterval
        end
    end

    function frame:Refresh()
        local config = MB.DB:GetElementConfig("coords")
        self.isMoving = isPlayerInMotion()
        local decimals = clampDecimals(config.coordsDecimals)
        local shouldForceLayout = self._lastRenderedText == nil

        if self._lastCoordsDecimals ~= decimals then
            shouldForceLayout = true
            self._lastCoordsDecimals = decimals
        end
        if self._lastShowLabel ~= config.showLabel then
            shouldForceLayout = true
            self._lastShowLabel = config.showLabel
        end

        if not self.isMoving and not shouldForceLayout then
            self:ApplyUpdateInterval()
            return
        end

        local mapId, roundedX, roundedY = getRoundedCoords(decimals)
        if not mapId then
            local missingText = "--, --"
            if shouldForceLayout or self._lastRenderedText ~= missingText then
                self:SetDisplayText(missingText, shouldForceLayout)
                self._lastRenderedText = missingText
                self._lastMapId = nil
                self._lastRoundedX = nil
                self._lastRoundedY = nil
            end
            self:ApplyUpdateInterval()
            return
        end

        if not shouldForceLayout
            and self._lastMapId == mapId
            and self._lastRoundedX == roundedX
            and self._lastRoundedY == roundedY then
            self:ApplyUpdateInterval()
            return
        end

        local text = formatCoords(roundedX, roundedY, decimals)
        local previousTextLength = self._lastRenderedText and string.len(self._lastRenderedText) or 0
        if string.len(text) > previousTextLength then
            shouldForceLayout = true
        end
        self:SetDisplayText(text, shouldForceLayout)
        self._lastRenderedText = text
        self._lastMapId = mapId
        self._lastRoundedX = roundedX
        self._lastRoundedY = roundedY
        self:ApplyUpdateInterval()
    end

    MB.Events:Register("PLAYER_ENTERING_WORLD", "COORDS_ELEMENT_WORLD", function()
        frame:Refresh()
    end)
    MB.Events:Register("PLAYER_STARTED_MOVING", "COORDS_ELEMENT_START_MOVE", function()
        frame.isMoving = true
        frame:ApplyUpdateInterval()
        frame:Refresh()
    end)
    MB.Events:Register("PLAYER_STOPPED_MOVING", "COORDS_ELEMENT_STOP_MOVE", function()
        frame.isMoving = false
        frame:ApplyUpdateInterval()
        frame:Refresh()
    end)

    MB.Throttle:Register("COORDS_ELEMENT", MB.Constants.UPDATE_INTERVALS.COORDS, function()
        frame:Refresh()
    end)

    frame:Refresh()
    return frame
end
