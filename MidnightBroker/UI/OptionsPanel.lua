local _, MB = ...

MB.OptionsPanel = {
    controls = {},
    currentElement = "time",
}
MB:RegisterModule("OptionsPanel", MB.OptionsPanel)

local elementLabelMap = {
    time = "Date-Time",
    zone = "Zone/Subzone",
    coords = "Coordinates",
    durability = "Durability",
    memory = "Memory",
    gold = "Gold",
    fps = "FPS",
    latency = "Latency",
}

local function buildFontDropdownOptions()
    local options = {}
    for _, font in ipairs(MB.Constants.FONT_OPTIONS or {}) do
        table.insert(options, {
            value = font.path,
            label = font.label,
        })
    end
    return options
end

local function buildDateFormatOptions()
    local options = {}
    for _, option in ipairs(MB.Constants.DATE_FORMAT_OPTIONS or {}) do
        table.insert(options, {
            value = option.value,
            label = option.label,
        })
    end
    return options
end

local function buildTimeFormatOptions()
    local options = {}
    for _, option in ipairs(MB.Constants.TIME_FORMAT_OPTIONS or {}) do
        table.insert(options, {
            value = option.value,
            label = option.label,
        })
    end
    return options
end

local function buildDateTimeLayoutOptions()
    local options = {}
    for _, option in ipairs(MB.Constants.DATETIME_LAYOUT_OPTIONS or {}) do
        table.insert(options, {
            value = option.value,
            label = option.label,
        })
    end
    return options
end

local function buildGoldFormatOptions()
    local options = {}
    for _, option in ipairs(MB.Constants.GOLD_FORMAT_OPTIONS or {}) do
        table.insert(options, {
            value = option.value,
            label = option.label,
        })
    end
    return options
end

local function buildZoneLayoutOptions()
    local options = {}
    for _, option in ipairs(MB.Constants.ZONE_LAYOUT_OPTIONS or {}) do
        table.insert(options, {
            value = option.value,
            label = option.label,
        })
    end
    return options
end

local function buildTextJustifyOptions()
    local options = {}
    for _, option in ipairs(MB.Constants.TEXT_JUSTIFY_OPTIONS or {}) do
        table.insert(options, {
            value = option.value,
            label = option.label,
        })
    end
    return options
end

local function buildMemoryTooltipOptions()
    local options = {}
    for _, option in ipairs(MB.Constants.MEMORY_TOOLTIP_OPTIONS or {}) do
        table.insert(options, {
            value = option.value,
            label = option.label,
        })
    end
    return options
end

local function getElementConfig()
    return MB.DB:GetElementConfig(MB.OptionsPanel.currentElement)
end

local function refreshElementVisuals()
    local element = MB.FrameManager:GetElement(MB.OptionsPanel.currentElement)
    if element then
        element:ApplyStyle()
        element:ApplyVisibility()
        element:ApplyPosition()
        element:Refresh()
    end
    MB.FrameManager:ApplyLockState()
    MB.FrameManager:RefreshAll()
end

function MB.OptionsPanel:RefreshControls()
    for _, control in ipairs(self.controls) do
        if control.Refresh then
            control:Refresh()
        end
    end
    self:RelayoutControls()
end

function MB.OptionsPanel:RelayoutControls()
    if not self.flowControls then
        return
    end

    local cursorY = -58
    for _, item in ipairs(self.flowControls) do
        local control = item.control
        local isVisible = true
        if item.isVisible then
            isVisible = item.isVisible()
        end

        if isVisible then
            if control.SetShown then
                control:SetShown(true)
            else
                control:Show()
            end
            if control.SetTopOffset then
                control:SetTopOffset(cursorY)
            end
            cursorY = cursorY - (control.layoutHeight or 30)
        else
            if control.SetShown then
                control:SetShown(false)
            else
                control:Hide()
            end
        end
    end

    local requiredHeight = math.max(980, math.abs(cursorY) + 80)
    if self.scrollContent then
        self.scrollContent:SetHeight(requiredHeight)
    end
end

function MB.OptionsPanel:BuildElementDropdown(panel, yOffset)
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 20, yOffset)
    title:SetText("Selected Element")

    local dropdown = CreateFrame("Frame", "MidnightBrokerElementDropdown", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -16, -2)

    UIDropDownMenu_SetWidth(dropdown, 180)

    UIDropDownMenu_Initialize(dropdown, function(self, _, _)
        for _, elementId in ipairs(MB.Constants.ELEMENT_ORDER) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = elementLabelMap[elementId]
            info.value = elementId
            info.func = function()
                MB.OptionsPanel.currentElement = elementId
                UIDropDownMenu_SetSelectedValue(dropdown, elementId)
                MB.OptionsPanel:RefreshControls()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(dropdown, self.currentElement)
    dropdown.title = title
    dropdown.layoutHeight = 54
    dropdown.SetTopOffset = function(self, offset)
        self.title:ClearAllPoints()
        self.title:SetPoint("TOPLEFT", 20, offset)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", -16, -2)
    end
    dropdown.SetShown = function(self, isShown)
        if isShown then
            self:Show()
            self.title:Show()
        else
            self:Hide()
            self.title:Hide()
        end
    end
    return dropdown
end

function MB.OptionsPanel:Initialize()
    local panel = CreateFrame("Frame", "MidnightBrokerOptionsPanel", UIParent)
    panel.name = "MidnightBroker"

    panel:Hide()
    panel:SetScript("OnShow", function()
        MB.OptionsPanel:RefreshControls()
    end)

    local scrollFrame = CreateFrame("ScrollFrame", "MidnightBrokerOptionsScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", "MidnightBrokerOptionsScrollContent", scrollFrame)
    content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    content:SetSize(620, 980)
    scrollFrame:SetScrollChild(content)

    self.flowControls = {}

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("MidnightBroker")

    local subtitle = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Standalone display elements and optional LibDataBroker data source.")

    local elementDropdown = self:BuildElementDropdown(content, -58)

    local unlockCheck = MB.ConfigWidgets:CreateCheckbox(
        content,
        "Unlock elements (drag to move)",
        "Allows moving enabled elements.",
        function() return MB.DB:GetProfile().unlocked end,
        function(value)
            MB.DB:GetProfile().unlocked = value and true or false
            MB.FrameManager:ApplyLockState()
        end,
        -112
    )

    local elementEnabledCheck = MB.ConfigWidgets:CreateCheckbox(
        content,
        "Enable selected element",
        "Shows or hides this element.",
        function() return getElementConfig().enabled end,
        function(value)
            getElementConfig().enabled = value and true or false
            refreshElementVisuals()
        end,
        -140
    )

    local showLabelCheck = MB.ConfigWidgets:CreateCheckbox(
        content,
        "Show label/title",
        "Toggles the static element label prefix.",
        function() return getElementConfig().showLabel end,
        function(value)
            getElementConfig().showLabel = value and true or false
            refreshElementVisuals()
        end,
        -172
    )

    local showBackgroundCheck = MB.ConfigWidgets:CreateCheckbox(
        content,
        "Show background",
        "Toggles background fill for this element frame.",
        function() return getElementConfig().showBackground end,
        function(value)
            getElementConfig().showBackground = value and true or false
            refreshElementVisuals()
        end,
        -200
    )

    local showBorderCheck = MB.ConfigWidgets:CreateCheckbox(
        content,
        "Show border",
        "Toggles border outline for this element frame.",
        function() return getElementConfig().showBorder end,
        function(value)
            getElementConfig().showBorder = value and true or false
            refreshElementVisuals()
        end,
        -228
    )

    local resetPosButton = MB.ConfigWidgets:CreateButton(content, "Reset selected position", 180, function()
        MB.FrameManager:ResetPosition(MB.OptionsPanel.currentElement)
        refreshElementVisuals()
    end, -258)

    local fontDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Font",
        220,
        buildFontDropdownOptions(),
        function() return getElementConfig().font end,
        function(value)
            getElementConfig().font = value
            refreshElementVisuals()
        end,
        -292
    )

    local textJustifyDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Text Justification",
        220,
        buildTextJustifyOptions(),
        function() return getElementConfig().textJustify end,
        function(value)
            getElementConfig().textJustify = value
            refreshElementVisuals()
        end,
        -348
    )

    local dateFormatDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Date Format",
        220,
        buildDateFormatOptions(),
        function() return getElementConfig().dateFormat end,
        function(value)
            getElementConfig().dateFormat = value
            refreshElementVisuals()
        end,
        -404
    )

    local timeFormatDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Time Format",
        220,
        buildTimeFormatOptions(),
        function() return getElementConfig().timeFormat end,
        function(value)
            getElementConfig().timeFormat = value
            refreshElementVisuals()
        end,
        -460
    )

    local dateTimeLayoutDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Date/Time Layout",
        220,
        buildDateTimeLayoutOptions(),
        function() return getElementConfig().dateTimeLayout end,
        function(value)
            getElementConfig().dateTimeLayout = value
            refreshElementVisuals()
        end,
        -516
    )

    local showIconCheck = MB.ConfigWidgets:CreateCheckbox(
        content,
        "Show icon",
        "Displays a small icon before the value.",
        function() return getElementConfig().showIcon end,
        function(value)
            getElementConfig().showIcon = value and true or false
            refreshElementVisuals()
        end,
        -404
    )

    local goldFormatDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Gold Format",
        220,
        buildGoldFormatOptions(),
        function() return getElementConfig().goldFormat end,
        function(value)
            getElementConfig().goldFormat = value
            refreshElementVisuals()
        end,
        -576
    )

    local zoneLayoutDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Zone Layout",
        220,
        buildZoneLayoutOptions(),
        function() return getElementConfig().zoneLayout end,
        function(value)
            getElementConfig().zoneLayout = value
            refreshElementVisuals()
        end,
        -632
    )

    local memoryTooltipDropdown = MB.ConfigWidgets:CreateDropdown(
        content,
        "Memory Tooltip Entries",
        220,
        buildMemoryTooltipOptions(),
        function() return getElementConfig().memoryTooltipMode end,
        function(value)
            getElementConfig().memoryTooltipMode = value
            refreshElementVisuals()
        end,
        -688
    )

    local coordsDecimalsSlider = MB.ConfigWidgets:CreateSlider(
        content,
        "Coordinates Decimals",
        0,
        2,
        1,
        function() return MB.DB:GetElementConfig("coords").coordsDecimals end,
        function(value)
            MB.DB:GetElementConfig("coords").coordsDecimals = math.floor(value + 0.5)
            refreshElementVisuals()
        end,
        -744
    )

    local coordsUpdateIntervalSlider = MB.ConfigWidgets:CreateSlider(
        content,
        "Coordinates Moving Update Interval (seconds)",
        0.05,
        1.0,
        0.05,
        function() return MB.DB:GetElementConfig("coords").coordsUpdateInterval end,
        function(value)
            MB.DB:GetElementConfig("coords").coordsUpdateInterval = value
            refreshElementVisuals()
        end,
        -800
    )

    local fontSizeSlider = MB.ConfigWidgets:CreateSlider(
        content,
        "Font Size",
        8,
        32,
        1,
        function() return getElementConfig().fontSize end,
        function(value)
            getElementConfig().fontSize = math.floor(value + 0.5)
            refreshElementVisuals()
        end,
        -856
    )

    local scaleSlider = MB.ConfigWidgets:CreateSlider(
        content,
        "Scale",
        0.5,
        2.0,
        0.05,
        function() return getElementConfig().scale end,
        function(value)
            getElementConfig().scale = value
            refreshElementVisuals()
        end,
        -912
    )

    local alphaSlider = MB.ConfigWidgets:CreateSlider(
        content,
        "Opacity",
        0.1,
        1.0,
        0.05,
        function() return getElementConfig().alpha end,
        function(value)
            getElementConfig().alpha = value
            refreshElementVisuals()
        end,
        -968
    )

    local textColorButton = MB.ConfigWidgets:CreateColorButton(
        content,
        "Text Color",
        function() return getElementConfig().textColor end,
        function(color)
            getElementConfig().textColor = color
            refreshElementVisuals()
        end,
        -1024
    )

    local bgColorButton = MB.ConfigWidgets:CreateColorButton(
        content,
        "Background Color",
        function() return getElementConfig().backgroundColor end,
        function(color)
            getElementConfig().backgroundColor = color
            refreshElementVisuals()
        end,
        -1054
    )

    local borderColorButton = MB.ConfigWidgets:CreateColorButton(
        content,
        "Border Color",
        function() return getElementConfig().borderColor end,
        function(color)
            getElementConfig().borderColor = color
            refreshElementVisuals()
        end,
        -1084
    )

    table.insert(self.controls, elementDropdown)
    table.insert(self.controls, unlockCheck)
    table.insert(self.controls, elementEnabledCheck)
    table.insert(self.controls, showLabelCheck)
    table.insert(self.controls, showBackgroundCheck)
    table.insert(self.controls, showBorderCheck)
    table.insert(self.controls, resetPosButton)
    table.insert(self.controls, fontDropdown)
    table.insert(self.controls, textJustifyDropdown)
    table.insert(self.controls, dateFormatDropdown)
    table.insert(self.controls, timeFormatDropdown)
    table.insert(self.controls, dateTimeLayoutDropdown)
    table.insert(self.controls, showIconCheck)
    table.insert(self.controls, goldFormatDropdown)
    table.insert(self.controls, zoneLayoutDropdown)
    table.insert(self.controls, memoryTooltipDropdown)
    table.insert(self.controls, coordsDecimalsSlider)
    table.insert(self.controls, coordsUpdateIntervalSlider)
    table.insert(self.controls, fontSizeSlider)
    table.insert(self.controls, scaleSlider)
    table.insert(self.controls, alphaSlider)
    table.insert(self.controls, textColorButton)
    table.insert(self.controls, bgColorButton)
    table.insert(self.controls, borderColorButton)

    table.insert(self.flowControls, { control = elementDropdown })
    table.insert(self.flowControls, { control = unlockCheck })
    table.insert(self.flowControls, { control = elementEnabledCheck })
    table.insert(self.flowControls, { control = showLabelCheck })
    table.insert(self.flowControls, { control = showBackgroundCheck })
    table.insert(self.flowControls, { control = showBorderCheck })
    table.insert(self.flowControls, {
        control = showIconCheck,
        isVisible = function() return MB.OptionsPanel.currentElement == "gold" end,
    })
    table.insert(self.flowControls, { control = resetPosButton })
    table.insert(self.flowControls, { control = fontDropdown })
    table.insert(self.flowControls, { control = textJustifyDropdown })
    table.insert(self.flowControls, {
        control = dateFormatDropdown,
        isVisible = function() return MB.OptionsPanel.currentElement == "time" end,
    })
    table.insert(self.flowControls, {
        control = timeFormatDropdown,
        isVisible = function() return MB.OptionsPanel.currentElement == "time" end,
    })
    table.insert(self.flowControls, {
        control = dateTimeLayoutDropdown,
        isVisible = function() return MB.OptionsPanel.currentElement == "time" end,
    })
    table.insert(self.flowControls, {
        control = goldFormatDropdown,
        isVisible = function() return MB.OptionsPanel.currentElement == "gold" end,
    })
    table.insert(self.flowControls, {
        control = zoneLayoutDropdown,
        isVisible = function() return MB.OptionsPanel.currentElement == "zone" end,
    })
    table.insert(self.flowControls, {
        control = memoryTooltipDropdown,
        isVisible = function() return MB.OptionsPanel.currentElement == "memory" end,
    })
    table.insert(self.flowControls, {
        control = coordsDecimalsSlider,
        isVisible = function() return MB.OptionsPanel.currentElement == "coords" end,
    })
    table.insert(self.flowControls, {
        control = coordsUpdateIntervalSlider,
        isVisible = function() return MB.OptionsPanel.currentElement == "coords" end,
    })
    table.insert(self.flowControls, { control = fontSizeSlider })
    table.insert(self.flowControls, { control = scaleSlider })
    table.insert(self.flowControls, { control = alphaSlider })
    table.insert(self.flowControls, { control = textColorButton })
    table.insert(self.flowControls, { control = bgColorButton })
    table.insert(self.flowControls, { control = borderColorButton })

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, "MidnightBroker")
        Settings.RegisterAddOnCategory(category)
        -- Retail 120001: OpenToCategory expects a numeric category ID.
        local categoryId = category.GetID and category:GetID() or nil
        if type(categoryId) == "number" then
            self.categoryId = categoryId
        else
            self.categoryId = nil
        end
    else
        InterfaceOptions_AddCategory(panel)
    end
    self.scrollFrame = scrollFrame
    self.scrollContent = content
    self.panel = panel
    self:RelayoutControls()
end

function MB.OptionsPanel:Open()
    if not self.panel then
        return
    end
    if Settings and Settings.OpenToCategory and type(self.categoryId) == "number" then
        local ok = pcall(Settings.OpenToCategory, self.categoryId)
        if ok then
            return
        end
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.panel)
        InterfaceOptionsFrame_OpenToCategory(self.panel)
    else
        MB:Print("Could not open options panel automatically.")
    end
end
