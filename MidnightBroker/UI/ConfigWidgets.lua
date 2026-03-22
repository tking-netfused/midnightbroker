local _, MB = ...

MB.ConfigWidgets = {}

function MB.ConfigWidgets:CreateCheckbox(parent, label, tooltip, onGet, onSet, yOffset)
    local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox.Text:SetText(label)
    checkbox.tooltipText = tooltip
    checkbox:SetPoint("TOPLEFT", 16, yOffset)

    checkbox:SetScript("OnClick", function(self)
        onSet(self:GetChecked())
    end)

    checkbox.Refresh = function()
        checkbox:SetChecked(onGet())
    end

    checkbox.layoutHeight = 28
    checkbox.SetTopOffset = function(self, offset)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", 16, offset)
    end

    return checkbox
end

function MB.ConfigWidgets:CreateSlider(parent, label, minValue, maxValue, step, onGet, onSet, yOffset)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 20, yOffset)
    slider:SetPoint("TOPRIGHT", -40, yOffset)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetHeight(16)
    slider.Text:SetText(label)
    slider.Low:SetText(tostring(minValue))
    slider.High:SetText(tostring(maxValue))

    local valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    valueText:SetPoint("LEFT", slider.Text, "RIGHT", 8, 0)
    valueText:SetText("")

    local function updateValueText(value)
        if step >= 1 then
            valueText:SetText(string.format("%.0f", value))
        else
            valueText:SetText(string.format("%.2f", value))
        end
    end

    local function sanitizeSliderValue(value)
        value = tonumber(value)
        if type(value) ~= "number" or value ~= value then
            return minValue
        end
        if value == math.huge then
            return maxValue
        end
        if value == -math.huge then
            return minValue
        end
        return math.max(minValue, math.min(maxValue, value))
    end

    slider:SetScript("OnValueChanged", function(_, value)
        updateValueText(value)
        if not slider._isRefreshing then
            onSet(value)
        end
    end)

    slider.Refresh = function()
        slider._isRefreshing = true
        local value = sanitizeSliderValue(onGet())
        local ok = pcall(slider.SetValue, slider, value)
        if not ok then
            slider:SetValue(minValue)
        end
        updateValueText(slider:GetValue())
        slider._isRefreshing = false
    end

    slider.layoutHeight = 56
    slider.SetTopOffset = function(self, offset)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", 20, offset)
        self:SetPoint("TOPRIGHT", -40, offset)
    end

    return slider
end

function MB.ConfigWidgets:CreateDropdown(parent, label, width, options, onGet, onSet, yOffset)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 20, yOffset)
    title:SetText(label)

    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -16, -2)
    UIDropDownMenu_SetWidth(dropdown, width)

    local function getLabelForValue(value)
        for _, option in ipairs(options) do
            if option.value == value then
                return option.label
            end
        end
        return tostring(value or "")
    end

    UIDropDownMenu_Initialize(dropdown, function(self, _, _)
        for _, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = option.value
            info.func = function()
                UIDropDownMenu_SetSelectedValue(dropdown, option.value)
                UIDropDownMenu_SetText(dropdown, option.label)
                onSet(option.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    dropdown.Refresh = function()
        local value = onGet()
        UIDropDownMenu_SetSelectedValue(dropdown, value)
        UIDropDownMenu_SetText(dropdown, getLabelForValue(value))
    end

    dropdown.title = title
    dropdown.SetShown = function(self, isShown)
        if isShown then
            self:Show()
            self.title:Show()
        else
            self:Hide()
            self.title:Hide()
        end
    end
    dropdown.layoutHeight = 56
    dropdown.SetTopOffset = function(self, offset)
        self.title:ClearAllPoints()
        self.title:SetPoint("TOPLEFT", 20, offset)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", -16, -2)
    end

    return dropdown
end

function MB.ConfigWidgets:CreateEditBox(parent, label, width, onGet, onSet, yOffset)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 20, yOffset)
    title:SetText(label)

    local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    edit:SetSize(width, 24)
    edit:SetAutoFocus(false)
    edit:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    edit:SetScript("OnEnterPressed", function(self)
        onSet(self:GetText())
        self:ClearFocus()
    end)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:SetText(onGet())
    end)

    edit.Refresh = function()
        edit:SetText(onGet())
    end

    return edit
end

function MB.ConfigWidgets:CreateButton(parent, text, width, onClick, yOffset)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    button:SetText(text)
    button:SetPoint("TOPLEFT", 20, yOffset)
    button:SetScript("OnClick", onClick)
    button.layoutHeight = 30
    button.SetTopOffset = function(self, offset)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", 20, offset)
    end
    return button
end

function MB.ConfigWidgets:CreateColorButton(parent, label, onGet, onSet, yOffset)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", 20, yOffset)
    button:SetSize(140, 22)
    button:SetText(label)

    local swatch = button:CreateTexture(nil, "ARTWORK")
    swatch:SetSize(18, 18)
    swatch:SetPoint("LEFT", button, "RIGHT", 8, 0)
    swatch:SetColorTexture(1, 1, 1, 1)

    local function refreshSwatch()
        local c = onGet()
        swatch:SetColorTexture(c.r, c.g, c.b, c.a)
    end

    local function normalizeColorPayload(payload, fallback)
        local base = fallback or { r = 1, g = 1, b = 1, a = 1 }
        local input = type(payload) == "table" and payload or {}
        local color = {
            r = type(input.r) == "number" and input.r or base.r or 1,
            g = type(input.g) == "number" and input.g or base.g or 1,
            b = type(input.b) == "number" and input.b or base.b or 1,
            a = base.a or 1,
        }

        if type(input.a) == "number" then
            color.a = input.a
        elseif type(input.opacity) == "number" then
            color.a = 1 - input.opacity
        end

        return color
    end

    button:SetScript("OnClick", function()
        local c = normalizeColorPayload(onGet(), { r = 1, g = 1, b = 1, a = 1 })
        local originalColor = { r = c.r, g = c.g, b = c.b, a = c.a }
        local pickerInfo = {
            r = c.r,
            g = c.g,
            b = c.b,
            opacity = 1 - c.a,
            hasOpacity = true,
            swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                local newColor = normalizeColorPayload({
                    r = nr,
                    g = ng,
                    b = nb,
                    opacity = OpacitySliderFrame and OpacitySliderFrame:GetValue() or nil,
                }, c)
                onSet(newColor)
                refreshSwatch()
            end,
            opacityFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                local newColor = normalizeColorPayload({
                    r = nr,
                    g = ng,
                    b = nb,
                    opacity = OpacitySliderFrame and OpacitySliderFrame:GetValue() or nil,
                }, c)
                onSet(newColor)
                refreshSwatch()
            end,
            cancelFunc = function(_)
                -- Ignore cancel payload alpha semantics and restore exact pre-open value.
                onSet({ r = originalColor.r, g = originalColor.g, b = originalColor.b, a = originalColor.a })
                refreshSwatch()
            end,
        }

        if ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow then
            ColorPickerFrame:SetupColorPickerAndShow(pickerInfo)
        else
            ColorPickerFrame.func = pickerInfo.swatchFunc
            ColorPickerFrame.opacityFunc = pickerInfo.opacityFunc
            ColorPickerFrame.cancelFunc = pickerInfo.cancelFunc
            ColorPickerFrame.hasOpacity = pickerInfo.hasOpacity
            ColorPickerFrame.opacity = pickerInfo.opacity
            ColorPickerFrame:SetColorRGB(pickerInfo.r, pickerInfo.g, pickerInfo.b)
            ColorPickerFrame:Show()
        end
    end)

    button.Refresh = refreshSwatch
    button.layoutHeight = 30
    button.SetTopOffset = function(self, offset)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", 20, offset)
    end
    return button
end
