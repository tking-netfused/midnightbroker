local addonName, MB = ...

MB.addonName = addonName
MB.modules = MB.modules or {}
MB.elements = MB.elements or {}
MB.util = MB.util or {}

function MB:RegisterModule(name, module)
    self.modules[name] = module
end

function MB:GetModule(name)
    return self.modules[name]
end

function MB:Print(message)
    local text = tostring(message or "")
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff7f7fff%s|r: %s", self.addonName, text))
end

function MB:Initialize()
    self.DB:Initialize()
    self.Events:Initialize()
    self.Throttle:Initialize()
    self.FrameManager:Initialize()
    self.LDB:Initialize()
    self.OptionsPanel:Initialize()
    self.SlashCommands:Initialize()
    self.Events:RegisterCoreEvents()
    self.Events:Fire("MB_INITIALIZED")
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(_, _, loadedAddon)
    if loadedAddon == addonName then
        MB:Initialize()
        initFrame:UnregisterEvent("ADDON_LOADED")
    end
end)
