local _, MB = ...

MB.BaseElement = {}

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

function MB.BaseElement:Create(elementId, label)
    local config = MB.DB:GetElementConfig(elementId)
    local frame = CreateFrame("Frame", "MidnightBroker_" .. elementId, UIParent, backdropTemplate)
    frame.elementId = elementId
    frame.label = label
    frame:SetSize(MB.Constants.MIN_FRAME_WIDTH, 24)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.text:SetPoint("LEFT", frame, "LEFT", 8, 0)
    frame.text:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetWordWrap(false)

    frame:SetScript("OnDragStart", function(self)
        if MB.DB:GetProfile().unlocked and config.enabled then
            self:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint(1)
        config.point = point
        config.relativePoint = relativePoint
        config.x = x
        config.y = y
    end)

    frame:SetScript("OnEnter", function(self)
        if self.OnHoverEnter then
            self:OnHoverEnter()
        end
    end)

    frame:SetScript("OnLeave", function(self)
        if self.OnHoverLeave then
            self:OnHoverLeave()
        end
    end)

    function frame:ApplyPosition()
        local cfg = MB.DB:GetElementConfig(self.elementId)
        self:ClearAllPoints()
        self:SetPoint(cfg.point or "CENTER", UIParent, cfg.relativePoint or "CENTER", cfg.x or 0, cfg.y or 0)
    end

    function frame:ApplyStyle()
        MB.Style:Apply(self, MB.DB:GetElementConfig(self.elementId))
        self:UpdateWidth()
    end

    function frame:ApplyVisibility()
        local cfg = MB.DB:GetElementConfig(self.elementId)
        if cfg.enabled then
            self:Show()
        else
            self:Hide()
        end
    end

    function frame:ApplyLockState(unlocked)
        local enabled = MB.DB:GetElementConfig(self.elementId).enabled
        local hasHoverHandlers = self.OnHoverEnter or self.OnHoverLeave
        local shouldEnableMouse = enabled and (unlocked or hasHoverHandlers)
        self:EnableMouse(shouldEnableMouse)
    end

    function frame:SetDisplayText(value)
        local config = MB.DB:GetElementConfig(self.elementId)
        local displayValue = value or "--"
        local text
        if config.showLabel then
            text = string.format("%s: %s", self.label, displayValue)
        else
            text = tostring(displayValue)
        end
        self.currentText = value or "--"
        self.text:SetText(text)
        self:UpdateWidth()
    end

    function frame:UpdateWidth()
        if not self.text then
            return
        end
        local config = MB.DB:GetElementConfig(self.elementId)
        local measuredTextWidth
        if self.text.GetUnboundedStringWidth then
            measuredTextWidth = self.text:GetUnboundedStringWidth()
        else
            measuredTextWidth = self.text:GetStringWidth()
        end
        measuredTextWidth = measuredTextWidth or 0
        local paddedWidth = measuredTextWidth + 20
        local elementMinWidth = MB.Constants.MIN_FRAME_WIDTH_BY_ELEMENT
            and MB.Constants.MIN_FRAME_WIDTH_BY_ELEMENT[self.elementId]
            or MB.Constants.MIN_FRAME_WIDTH
        local minWidth = config.showLabel and elementMinWidth or 70
        local width = clamp(paddedWidth, minWidth, MB.Constants.MAX_FRAME_WIDTH)
        self:SetWidth(width)
    end

    frame:ApplyPosition()
    frame:ApplyStyle()
    frame:ApplyVisibility()
    return frame
end
