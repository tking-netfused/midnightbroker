local _, MB = ...

local DurabilityElement = {}
MB.elements.durability = DurabilityElement

local SLOT_LABELS = {
    [1] = _G["HEADSLOT"] or "Head",
    [2] = _G["NECKSLOT"] or "Neck",
    [3] = _G["SHOULDERSLOT"] or "Shoulder",
    [5] = _G["CHESTSLOT"] or "Chest",
    [6] = _G["WAISTSLOT"] or "Waist",
    [7] = _G["LEGSLOT"] or "Legs",
    [8] = _G["FEETSLOT"] or "Feet",
    [9] = _G["WRISTSLOT"] or "Wrist",
    [10] = _G["HANDSSLOT"] or "Hands",
    [11] = _G["FINGER0SLOT"] or "Finger 1",
    [12] = _G["FINGER1SLOT"] or "Finger 2",
    [13] = _G["TRINKET0SLOT"] or "Trinket 1",
    [14] = _G["TRINKET1SLOT"] or "Trinket 2",
    [15] = _G["BACKSLOT"] or "Back",
    [16] = _G["MAINHANDSLOT"] or "Main Hand",
    [17] = _G["SECONDARYHANDSLOT"] or "Off Hand",
}

local function getSlotLabel(slotId)
    return SLOT_LABELS[slotId] or string.format("Slot %d", slotId)
end

local function getDurabilityPercent()
    local lowestPercent = 100
    local hasData = false

    for _, slotId in ipairs(MB.Constants.DURABILITY_SLOTS) do
        local current, maxValue = GetInventoryItemDurability(slotId)
        if current and maxValue and maxValue > 0 then
            hasData = true
            local percent = (current / maxValue) * 100
            if percent < lowestPercent then
                lowestPercent = percent
            end
        end
    end

    if not hasData then
        return "N/A"
    end
    return string.format("%.0f%%", lowestPercent)
end

local function buildDurabilityBreakdown()
    local lowestPercent = 100
    local hasData = false
    local entries = {}

    for _, slotId in ipairs(MB.Constants.DURABILITY_SLOTS) do
        local current, maxValue = GetInventoryItemDurability(slotId)
        if current and maxValue and maxValue > 0 then
            hasData = true
            local percent = (current / maxValue) * 100
            if percent < lowestPercent then
                lowestPercent = percent
            end

            local itemLink = GetInventoryItemLink("player", slotId)
            local itemName = itemLink and GetItemInfo(itemLink) or nil
            table.insert(entries, {
                slot = getSlotLabel(slotId),
                name = itemName or itemLink or "Unknown Item",
                current = current,
                maxValue = maxValue,
                percent = percent,
            })
        end
    end

    table.sort(entries, function(a, b)
        return a.percent < b.percent
    end)

    return hasData, lowestPercent, entries
end

function DurabilityElement:Create()
    local frame = MB.BaseElement:Create("durability", "Durability")

    function frame:Refresh()
        frame:SetDisplayText(getDurabilityPercent())
    end

    MB.Events:Register("UPDATE_INVENTORY_DURABILITY", "DURA_ELEMENT", function()
        frame:Refresh()
    end)
    MB.Events:Register("PLAYER_ENTERING_WORLD", "DURA_ELEMENT_WORLD", function()
        frame:Refresh()
    end)

    function frame:OnHoverEnter()
        local hasData, lowestPercent, entries = buildDurabilityBreakdown()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Durability Breakdown")

        if not hasData then
            GameTooltip:AddLine("No durability data", 0.8, 0.8, 0.8)
            GameTooltip:Show()
            return
        end

        GameTooltip:AddLine(string.format("Lowest: %.0f%%", lowestPercent), 1, 1, 1)
        GameTooltip:AddLine(" ")
        for _, entry in ipairs(entries) do
            local valueText = string.format("%d/%d (%.0f%%)", entry.current, entry.maxValue, entry.percent)
            GameTooltip:AddDoubleLine(
                string.format("%s: %s", entry.slot, entry.name),
                valueText,
                0.85,
                0.85,
                0.85,
                1,
                1,
                1
            )
        end
        GameTooltip:Show()
    end

    function frame:OnHoverLeave()
        GameTooltip:Hide()
    end

    frame:Refresh()
    return frame
end
