local _, MB = ...

local MemoryElement = {}
MB.elements.memory = MemoryElement

local function formatMemory(valueKB)
    if valueKB >= 1024 then
        return string.format("%.2f MB", valueKB / 1024)
    end
    return string.format("%.0f KB", valueKB)
end

local function getMemoryText()
    UpdateAddOnMemoryUsage()
    local total = 0
    local getCount = C_AddOns and C_AddOns.GetNumAddOns or GetNumAddOns
    local getUsage = C_AddOns and C_AddOns.GetAddOnMemoryUsage or GetAddOnMemoryUsage

    for index = 1, getCount() do
        total = total + getUsage(index)
    end

    return formatMemory(total)
end

local function buildAddonMemoryList()
    UpdateAddOnMemoryUsage()

    local getCount = C_AddOns and C_AddOns.GetNumAddOns or GetNumAddOns
    local getUsage = C_AddOns and C_AddOns.GetAddOnMemoryUsage or GetAddOnMemoryUsage
    local getTitle = function(index)
        if C_AddOns and C_AddOns.GetAddOnMetadata then
            return C_AddOns.GetAddOnMetadata(index, "Title")
        end
        return GetAddOnMetadata(index, "Title")
    end
    local getName = C_AddOns and C_AddOns.GetAddOnInfo and function(index)
        local info = C_AddOns.GetAddOnInfo(index)
        if type(info) == "table" then
            return info.name
        end
        return info
    end or function(index)
        local name = GetAddOnInfo(index)
        return name
    end
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

    local entries = {}
    local total = 0
    for index = 1, getCount() do
        local usageKB = getUsage(index) or 0
        total = total + usageKB
        local addonName = getName(index)
        if addonName and isLoaded(addonName) then
            local title = getTitle(index)
            table.insert(entries, {
                name = (title and title ~= "") and title or addonName,
                usage = usageKB,
            })
        end
    end

    table.sort(entries, function(a, b)
        return a.usage > b.usage
    end)

    return total, entries
end

function MemoryElement:Create()
    local frame = MB.BaseElement:Create("memory", "Memory")

    function frame:Refresh()
        frame:SetDisplayText(getMemoryText())
    end

    MB.Events:Register("PLAYER_ENTERING_WORLD", "MEM_ELEMENT_WORLD", function()
        frame:Refresh()
    end)

    MB.Throttle:Register("MEMORY_ELEMENT", MB.Constants.UPDATE_INTERVALS.MEMORY, function()
        frame:Refresh()
    end)

    function frame:OnHoverEnter()
        local totalKB, entries = buildAddonMemoryList()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Memory Usage")
        GameTooltip:AddLine(string.format("Total: %s", formatMemory(totalKB)), 1, 1, 1)

        if #entries == 0 then
            GameTooltip:AddLine("No loaded addons", 0.8, 0.8, 0.8)
        else
            GameTooltip:AddLine(" ")
            for _, entry in ipairs(entries) do
                GameTooltip:AddDoubleLine(entry.name, formatMemory(entry.usage), 0.85, 0.85, 0.85, 1, 1, 1)
            end
        end

        GameTooltip:Show()
    end

    function frame:OnHoverLeave()
        GameTooltip:Hide()
    end

    frame:Refresh()
    return frame
end
