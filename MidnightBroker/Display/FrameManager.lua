local _, MB = ...

MB.FrameManager = {
    instances = {},
}
MB:RegisterModule("FrameManager", MB.FrameManager)

function MB.FrameManager:Initialize()
    self.registry = MB.elements
end

function MB.FrameManager:CreateAllElements()
    for _, elementId in ipairs(MB.Constants.ELEMENT_ORDER) do
        local elementModule = self.registry[elementId]
        if elementModule and not self.instances[elementId] then
            self.instances[elementId] = elementModule:Create()
        end
    end
end

function MB.FrameManager:GetElement(elementId)
    return self.instances[elementId]
end

function MB.FrameManager:GetElementText(elementId)
    local element = self.instances[elementId]
    return element and element.currentText or "--"
end

function MB.FrameManager:RefreshAll()
    for _, element in pairs(self.instances) do
        if element.Refresh then
            element:Refresh()
        end
    end
end

function MB.FrameManager:ApplyLockState()
    local unlocked = MB.DB:GetProfile().unlocked
    for _, element in pairs(self.instances) do
        if element.ApplyLockState then
            element:ApplyLockState(unlocked)
        end
    end
end

function MB.FrameManager:ToggleLock()
    local profile = MB.DB:GetProfile()
    profile.unlocked = not profile.unlocked
    self:ApplyLockState()
    MB:Print(profile.unlocked and "Elements unlocked." or "Elements locked.")
end

function MB.FrameManager:ResetPosition(elementId)
    if elementId == "all" then
        for _, id in ipairs(MB.Constants.ELEMENT_ORDER) do
            MB.DB:ResetElementPosition(id)
            if self.instances[id] then
                self.instances[id]:ApplyPosition()
            end
        end
        return
    end

    MB.DB:ResetElementPosition(elementId)
    if self.instances[elementId] then
        self.instances[elementId]:ApplyPosition()
    end
end

local function applyElementVisuals(element)
    if not element then
        return
    end
    if element.ApplyStyle then
        element:ApplyStyle()
    end
    if element.ApplyVisibility then
        element:ApplyVisibility()
    end
    if element.Refresh then
        element:Refresh()
    end
end

function MB.FrameManager:ResetStyle(elementId)
    if elementId == "all" then
        for _, id in ipairs(MB.Constants.ELEMENT_ORDER) do
            MB.DB:ResetElementStyle(id)
            MB.DB:SanitizeElementStyle(id)
            applyElementVisuals(self.instances[id])
        end
        self:ApplyLockState()
        return
    end

    MB.DB:ResetElementStyle(elementId)
    MB.DB:SanitizeElementStyle(elementId)
    applyElementVisuals(self.instances[elementId])
    self:ApplyLockState()
end
