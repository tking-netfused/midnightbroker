local _, MB = ...

MB.Style = {}
MB:RegisterModule("Style", MB.Style)

local function unpackColor(color, fallback)
    local data = color or fallback
    return data.r or 1, data.g or 1, data.b or 1, data.a or 1
end

function MB.Style:Apply(frame, config)
    if not frame or not config then
        return
    end

    frame:SetScale(config.scale or 1)
    frame:SetAlpha(config.alpha or 1)

    if frame.text then
        frame.text:SetFont(config.font or MB.Constants.DEFAULT_FONT, config.fontSize or 13, "OUTLINE")
        frame.text:SetTextColor(unpackColor(config.textColor, { r = 1, g = 1, b = 1, a = 1 }))
    end

    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        local bgR, bgG, bgB, bgA = unpackColor(config.backgroundColor, { r = 0, g = 0, b = 0, a = 0.45 })
        local borderR, borderG, borderB, borderA = unpackColor(config.borderColor, { r = 0.4, g = 0.4, b = 0.4, a = 1 })

        if config.showBackground == false then
            bgA = 0
        end
        if config.showBorder == false then
            borderA = 0
        end

        frame:SetBackdropColor(bgR, bgG, bgB, bgA)
        frame:SetBackdropBorderColor(borderR, borderG, borderB, borderA)
    end
end
