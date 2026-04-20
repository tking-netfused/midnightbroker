local _, MB = ...

MB.DB = {}
MB:RegisterModule("DB", MB.DB)

local function deepCopy(source)
    if type(source) ~= "table" then
        return source
    end
    local target = {}
    for key, value in pairs(source) do
        target[key] = deepCopy(value)
    end
    return target
end

local function mergeDefaults(target, defaults)
    for key, defaultValue in pairs(defaults) do
        local valueType = type(defaultValue)
        if valueType == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            mergeDefaults(target[key], defaultValue)
        elseif target[key] == nil then
            target[key] = defaultValue
        end
    end
end

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

local function sanitizeColor(color, defaultColor)
    local safe = type(color) == "table" and color or {}
    return {
        r = clamp(type(safe.r) == "number" and safe.r or defaultColor.r, 0, 1),
        g = clamp(type(safe.g) == "number" and safe.g or defaultColor.g, 0, 1),
        b = clamp(type(safe.b) == "number" and safe.b or defaultColor.b, 0, 1),
        a = clamp(type(safe.a) == "number" and safe.a or defaultColor.a, 0, 1),
    }
end

local function isOptionValue(optionList, value)
    for _, option in ipairs(optionList or {}) do
        if option.value == value then
            return true
        end
    end
    return false
end

local function sanitizeBoolean(value, defaultValue)
    if type(value) == "boolean" then
        return value
    end
    return defaultValue and true or false
end

function MB.DB:Initialize()
    if type(MidnightBrokerDB) ~= "table" then
        MidnightBrokerDB = {}
    end
    mergeDefaults(MidnightBrokerDB, MB.Defaults)
    self.profile = MidnightBrokerDB.profile
    for _, elementId in ipairs(MB.Constants.ELEMENT_ORDER) do
        self:SanitizeElementStyle(elementId)
    end
end

function MB.DB:GetProfile()
    return self.profile
end

function MB.DB:GetElementConfig(elementId)
    local profile = self:GetProfile()
    profile.elements[elementId] = profile.elements[elementId] or deepCopy(MB.Defaults.profile.elements[elementId] or {})
    return profile.elements[elementId]
end

function MB.DB:ResetElementPosition(elementId)
    local defaults = MB.Defaults.profile.elements[elementId]
    if not defaults then
        return
    end
    local config = self:GetElementConfig(elementId)
    config.point = defaults.point
    config.relativePoint = defaults.relativePoint
    config.x = defaults.x
    config.y = defaults.y
end

function MB.DB:SanitizeElementStyle(elementId)
    local defaults = MB.Defaults.profile.elements[elementId]
    if not defaults then
        return false
    end

    local config = self:GetElementConfig(elementId)
    config.font = type(config.font) == "string" and config.font ~= "" and config.font or defaults.font
    config.fontSize = type(config.fontSize) == "number" and clamp(config.fontSize, 6, 64) or defaults.fontSize
    if not isOptionValue(MB.Constants.TEXT_JUSTIFY_OPTIONS, config.textJustify) then
        config.textJustify = defaults.textJustify
    end
    config.showLabel = sanitizeBoolean(config.showLabel, defaults.showLabel)
    config.showBackground = sanitizeBoolean(config.showBackground, defaults.showBackground)
    config.showBorder = sanitizeBoolean(config.showBorder, defaults.showBorder)
    if elementId == "time" then
        if not isOptionValue(MB.Constants.DATE_FORMAT_OPTIONS, config.dateFormat) then
            config.dateFormat = defaults.dateFormat
        end
        if not isOptionValue(MB.Constants.TIME_FORMAT_OPTIONS, config.timeFormat) then
            config.timeFormat = defaults.timeFormat
        end
        if not isOptionValue(MB.Constants.DATETIME_LAYOUT_OPTIONS, config.dateTimeLayout) then
            config.dateTimeLayout = defaults.dateTimeLayout
        end
    elseif elementId == "zone" then
        if not isOptionValue(MB.Constants.ZONE_LAYOUT_OPTIONS, config.zoneLayout) then
            config.zoneLayout = defaults.zoneLayout
        end
    elseif elementId == "memory" then
        if not isOptionValue(MB.Constants.MEMORY_TOOLTIP_OPTIONS, config.memoryTooltipMode) then
            config.memoryTooltipMode = defaults.memoryTooltipMode
        end
    elseif elementId == "coords" then
        config.coordsDecimals = type(config.coordsDecimals) == "number" and clamp(math.floor(config.coordsDecimals + 0.5), 0, 2) or defaults.coordsDecimals
        config.coordsUpdateInterval = type(config.coordsUpdateInterval) == "number" and clamp(config.coordsUpdateInterval, 0.05, 1.0) or defaults.coordsUpdateInterval
    elseif elementId == "gold" then
        config.showIcon = sanitizeBoolean(config.showIcon, defaults.showIcon)
        if not isOptionValue(MB.Constants.GOLD_FORMAT_OPTIONS, config.goldFormat) then
            config.goldFormat = defaults.goldFormat
        end
    end
    config.alpha = type(config.alpha) == "number" and clamp(config.alpha, 0, 1) or defaults.alpha
    config.scale = type(config.scale) == "number" and clamp(config.scale, 0.2, 3) or defaults.scale
    config.textColor = sanitizeColor(config.textColor, defaults.textColor)
    config.backgroundColor = sanitizeColor(config.backgroundColor, defaults.backgroundColor)
    config.borderColor = sanitizeColor(config.borderColor, defaults.borderColor)
    return true
end

function MB.DB:ResetElementStyle(elementId)
    local defaults = MB.Defaults.profile.elements[elementId]
    if not defaults then
        return false
    end

    local config = self:GetElementConfig(elementId)
    config.font = defaults.font
    config.fontSize = defaults.fontSize
    config.textJustify = defaults.textJustify
    config.showLabel = defaults.showLabel
    config.showBackground = defaults.showBackground
    config.showBorder = defaults.showBorder
    if defaults.dateFormat then
        config.dateFormat = defaults.dateFormat
    end
    if defaults.timeFormat then
        config.timeFormat = defaults.timeFormat
    end
    if defaults.dateTimeLayout then
        config.dateTimeLayout = defaults.dateTimeLayout
    end
    if defaults.coordsDecimals then
        config.coordsDecimals = defaults.coordsDecimals
    end
    if defaults.coordsUpdateInterval then
        config.coordsUpdateInterval = defaults.coordsUpdateInterval
    end
    if defaults.showIcon ~= nil then
        config.showIcon = defaults.showIcon
    end
    config.alpha = defaults.alpha
    config.scale = defaults.scale
    config.textColor = deepCopy(defaults.textColor)
    config.backgroundColor = deepCopy(defaults.backgroundColor)
    config.borderColor = deepCopy(defaults.borderColor)
    return true
end
