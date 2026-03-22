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
    frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -4)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")
    frame.text:SetWordWrap(false)
    frame.text:SetWidth(MB.Constants.MIN_FRAME_WIDTH - 16)
    frame.measureText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.measureText:Hide()

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
        local cfg = MB.DB:GetElementConfig(self.elementId)
        MB.Style:Apply(self, cfg)
        self.text:SetJustifyH(cfg.textJustify or "LEFT")
        self.measureText:SetFont(cfg.font or MB.Constants.DEFAULT_FONT, cfg.fontSize or 13, "OUTLINE")
        self:UpdateHeight()
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

    function frame:SetDisplayText(value, forceLayout)
        local config = MB.DB:GetElementConfig(self.elementId)
        local displayValue = value or "--"
        local text
        if config.showLabel then
            text = string.format("%s: %s", self.label, displayValue)
        else
            text = tostring(displayValue)
        end
        local isMultiline = string.find(text, "\n", 1, true) ~= nil
        self.currentText = value or "--"

        if self._renderedText == text and self._renderedMultiline == isMultiline then
            return
        end

        self.text:SetWordWrap(isMultiline)
        self.text:SetMaxLines(isMultiline and 0 or 1)
        self.text:SetText(text)
        self._renderedText = text
        self._renderedMultiline = isMultiline
        if forceLayout or not self.skipAutoResize then
            self:UpdateHeight()
            self:UpdateWidth()
        end
    end

    function frame:UpdateHeight()
        if not self.text then
            return
        end
        local textValue = self.text:GetText() or ""
        local lineCount = 1
        if textValue ~= "" then
            lineCount = 1 + select(2, string.gsub(textValue, "\n", ""))
        end
        local _, fontSize = self.text:GetFont()
        fontSize = type(fontSize) == "number" and fontSize or 13
        local lineHeight = math.max(12, fontSize + 2)
        local paddedHeight = (lineCount * lineHeight) + 8
        self:SetHeight(math.max(24, paddedHeight))
    end

    function frame:UpdateWidth()
        if not self.text then
            return
        end
        local config = MB.DB:GetElementConfig(self.elementId)
        local measuredTextWidth = 0
        local fullText = self.text:GetText() or ""
        local hasAnyLine = false

        -- Measure each line independently so multiline strings size to the widest line.
        for line in string.gmatch(fullText .. "\n", "(.-)\n") do
            hasAnyLine = true
            self.measureText:SetText(line)
            local lineWidth = self.measureText:GetStringWidth() or 0
            if lineWidth > measuredTextWidth then
                measuredTextWidth = lineWidth
            end
        end

        if not hasAnyLine then
            measuredTextWidth = 0
        end

        local paddedWidth = measuredTextWidth + 24
        local elementMinWidth = MB.Constants.MIN_FRAME_WIDTH_BY_ELEMENT
            and MB.Constants.MIN_FRAME_WIDTH_BY_ELEMENT[self.elementId]
            or MB.Constants.MIN_FRAME_WIDTH
        local minWidth = config.showLabel and elementMinWidth or 70
        local width = clamp(paddedWidth, minWidth, MB.Constants.MAX_FRAME_WIDTH)
        self:SetWidth(width)
        self.text:SetWidth(math.max(1, width - 16))
    end

    frame:ApplyPosition()
    frame:ApplyStyle()
    frame:ApplyVisibility()
    return frame
end
