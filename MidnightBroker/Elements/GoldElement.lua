local _, MB = ...

local GoldElement = {}
MB.elements.gold = GoldElement

local function getGoldText()
    local copper = GetMoney() or 0
    local cpg = MB.Constants.COPPER_PER_GOLD
    local cps = MB.Constants.COPPER_PER_SILVER
    local gold = math.floor(copper / cpg)
    local silver = math.floor((copper % cpg) / cps)
    local remainderCopper = copper % cps

    if gold > 0 then
        return string.format("%dg %02ds %02dc", gold, silver, remainderCopper)
    elseif silver > 0 then
        return string.format("%ds %02dc", silver, remainderCopper)
    end
    return string.format("%dc", remainderCopper)
end

function GoldElement:Create()
    local frame = MB.BaseElement:Create("gold", "Gold")

    function frame:Refresh()
        self:SetDisplayText(getGoldText())
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
