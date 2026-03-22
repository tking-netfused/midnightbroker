local _, MB = ...

MB.LDB = {
    dataObject = nil,
}
MB:RegisterModule("LDB", MB.LDB)

local function formatNumberWithCommas(value)
    local formatted = tostring(math.floor(value or 0))
    while true do
        local replaced, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        formatted = replaced
        if count == 0 then
            break
        end
    end
    return formatted
end

local function formatMoneyText(copper)
    local cpg = MB.Constants.COPPER_PER_GOLD
    local cps = MB.Constants.COPPER_PER_SILVER
    local gold = math.floor(copper / cpg)
    local silver = math.floor((copper % cpg) / cps)
    local remainderCopper = copper % cps

    if gold > 0 then
        return string.format("%sg %02ds %02dc", formatNumberWithCommas(gold), silver, remainderCopper)
    elseif silver > 0 then
        return string.format("%ds %02dc", silver, remainderCopper)
    end
    return string.format("%dc", remainderCopper)
end

local function getFPSLabel()
    return string.format("%d FPS", math.floor((GetFramerate() or 0) + 0.5))
end

local function getLatencyLabel()
    local _, _, home, world = GetNetStats()
    if not home or not world then
        return "--/-- ms"
    end
    return string.format("%d/%d ms", home, world)
end

local function buildBrokerText(profile)
    local timeText = MB.FrameManager:GetElementText("time")
    local zoneText = MB.FrameManager:GetElementText("zone")
    local coordsText = MB.FrameManager:GetElementText("coords")
    local durabilityText = MB.FrameManager:GetElementText("durability")
    local memoryText = MB.FrameManager:GetElementText("memory")
    local metricConfig = profile.brokerMetrics or {}
    local segments = {
        timeText,
        zoneText,
        coordsText,
        string.format("Dura %s", durabilityText),
        string.format("Mem %s", memoryText),
    }

    if metricConfig.showGold ~= false then
        table.insert(segments, string.format("Gold %s", formatMoneyText(GetMoney() or 0)))
    end
    if metricConfig.showFPS ~= false then
        table.insert(segments, getFPSLabel())
    end
    if metricConfig.showLatency ~= false then
        table.insert(segments, string.format("Latency %s", getLatencyLabel()))
    end

    return table.concat(segments, " | ")
end

function MB.LDB:Initialize()
    local profile = MB.DB:GetProfile()
    if not profile.brokerEnabled then
        return
    end

    -- Assumption: some packs expose the lib via LibStub, some as a global.
    local ldb = _G.LibDataBroker
    if not ldb and _G.LibStub and _G.LibStub.GetLibrary then
        ldb = _G.LibStub:GetLibrary("LibDataBroker-1.1", true)
    end
    if not ldb then
        self.available = false
        return
    end
    self.available = true

    self.dataObject = ldb:NewDataObject("MidnightBroker", {
        type = "data source",
        text = buildBrokerText(profile),
        icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
        OnClick = function(_, button)
            if button == "LeftButton" then
                MB.OptionsPanel:Open()
            elseif button == "RightButton" then
                MB.FrameManager:ToggleLock()
            end
        end,
        OnTooltipShow = function(tooltip)
            local metricConfig = profile.brokerMetrics or {}
            tooltip:AddLine("MidnightBroker")
            tooltip:AddLine("Left click: Options", 1, 1, 1)
            tooltip:AddLine("Right click: Lock/Unlock", 1, 1, 1)
            tooltip:AddLine(buildBrokerText(profile), 0.8, 0.8, 1, true)
            tooltip:AddLine(" ")
            if metricConfig.showGold ~= false then
                tooltip:AddLine(string.format("Gold: %s", formatMoneyText(GetMoney() or 0)), 1, 0.82, 0)
            end
            if metricConfig.showFPS ~= false then
                tooltip:AddLine(string.format("Frame Rate: %s", getFPSLabel()), 0.6, 1, 0.6)
            end
            if metricConfig.showLatency ~= false then
                tooltip:AddLine(string.format("Latency (Home/World): %s", getLatencyLabel()), 0.6, 0.8, 1)
            end
        end,
    })

    MB.Throttle:Register("LDB_UPDATE", MB.Constants.UPDATE_INTERVALS.BROKER, function()
        if self.dataObject then
            self.dataObject.text = buildBrokerText(profile)
        end
    end)
end
