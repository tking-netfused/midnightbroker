local _, MB = ...

local GoldElement = {}
MB.elements.gold = GoldElement

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

local function formatGold(copper, formatMode)
    copper = copper or 0
    local cpg = MB.Constants.COPPER_PER_GOLD
    local cps = MB.Constants.COPPER_PER_SILVER
    local gold = math.floor(copper / cpg)
    local silver = math.floor((copper % cpg) / cps)
    local remainderCopper = copper % cps

    if formatMode == "g" then
        return string.format("%sg", formatNumberWithCommas(gold))
    end

    if gold > 0 then
        return string.format("%sg %02ds %02dc", formatNumberWithCommas(gold), silver, remainderCopper)
    elseif silver > 0 then
        return string.format("%ds %02dc", silver, remainderCopper)
    end
    return string.format("%dc", remainderCopper)
end

function GoldElement:Create()
    local frame = MB.BaseElement:Create("gold", "Gold")

    function frame:Refresh()
        local config = MB.DB:GetElementConfig("gold")
        local prefix = config.showIcon and "|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:0:2|t" or ""
        self:SetDisplayText(prefix .. formatGold(GetMoney() or 0, config.goldFormat))
    end

    MB.Events:Register("PLAYER_MONEY", "GOLD_ELEMENT_MONEY", function()
        frame:Refresh()
    end)

    MB.Throttle:Register("GOLD_ELEMENT", MB.Constants.UPDATE_INTERVALS.GOLD, function()
        frame:Refresh()
    end)

    frame:Refresh()
    return frame
end
