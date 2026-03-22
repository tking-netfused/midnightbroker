local _, MB = ...

MB.Events = {
    listeners = {},
}
MB:RegisterModule("Events", MB.Events)

function MB.Events:Initialize()
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        self:Fire(event, ...)
    end)
end

function MB.Events:Register(eventName, ownerKey, callback)
    self.listeners[eventName] = self.listeners[eventName] or {}
    self.listeners[eventName][ownerKey] = callback
    self.frame:RegisterEvent(eventName)
end

function MB.Events:Unregister(eventName, ownerKey)
    local bucket = self.listeners[eventName]
    if not bucket then
        return
    end
    bucket[ownerKey] = nil
    if next(bucket) == nil then
        self.listeners[eventName] = nil
        self.frame:UnregisterEvent(eventName)
    end
end

function MB.Events:Fire(eventName, ...)
    local bucket = self.listeners[eventName]
    if not bucket then
        return
    end
    for _, callback in pairs(bucket) do
        callback(...)
    end
end

function MB.Events:RegisterCoreEvents()
    self:Register("PLAYER_ENTERING_WORLD", "MB_BOOTSTRAP", function()
        MB.FrameManager:CreateAllElements()
        MB.FrameManager:ApplyLockState()
        MB.FrameManager:RefreshAll()
        MB.Events:Unregister("PLAYER_ENTERING_WORLD", "MB_BOOTSTRAP")
    end)
end
