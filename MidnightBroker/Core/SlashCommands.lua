local _, MB = ...

MB.SlashCommands = {}
MB:RegisterModule("SlashCommands", MB.SlashCommands)

local function normalizeElement(token)
    if not token then
        return nil
    end
    token = token:lower()
    for _, elementId in ipairs(MB.Constants.ELEMENT_ORDER) do
        if elementId == token then
            return elementId
        end
    end
    return nil
end

local function printHelp()
    MB:Print("Commands:")
    MB:Print("/mb options - Open options panel")
    MB:Print("/mb lock - Lock elements")
    MB:Print("/mb unlock - Unlock elements")
    MB:Print("/mb toggle <time|zone|coords|durability|memory|gold|fps|latency>")
    MB:Print("/mb reset <time|zone|coords|durability|memory|gold|fps|latency|all>")
    MB:Print("/mb resetstyle <time|zone|coords|durability|memory|gold|fps|latency|all>")
end

function MB.SlashCommands:Initialize()
    SLASH_MIDNIGHTBROKER1 = "/midnightbroker"
    SLASH_MIDNIGHTBROKER2 = "/mb"

    SlashCmdList.MIDNIGHTBROKER = function(message)
        local command, arg = string.match(message or "", "^(%S*)%s*(.-)$")
        command = string.lower(command or "")

        if command == "" or command == "help" then
            printHelp()
            return
        end

        if command == "options" then
            local ok, err = pcall(function()
                MB.OptionsPanel:Open()
            end)
            if not ok then
                MB:Print("Failed to open options. Try opening via Esc > Options > AddOns.")
                MB:Print(err)
            end
            return
        end

        if command == "lock" then
            MB.DB:GetProfile().unlocked = false
            MB.FrameManager:ApplyLockState()
            MB:Print("Elements locked.")
            return
        end

        if command == "unlock" then
            MB.DB:GetProfile().unlocked = true
            MB.FrameManager:ApplyLockState()
            MB:Print("Elements unlocked.")
            return
        end

        if command == "toggle" then
            local elementId = normalizeElement(arg)
            if not elementId then
                MB:Print("Unknown element. Use time, zone, coords, durability, memory, gold, fps, or latency.")
                return
            end
            local config = MB.DB:GetElementConfig(elementId)
            config.enabled = not config.enabled
            local element = MB.FrameManager:GetElement(elementId)
            if element then
                element:ApplyVisibility()
            end
            MB.FrameManager:ApplyLockState()
            MB:Print(string.format("%s %s.", elementId, config.enabled and "enabled" or "disabled"))
            return
        end

        if command == "reset" then
            local requested = (arg and arg ~= "") and arg:lower() or "all"
            if requested ~= "all" and not normalizeElement(requested) then
                MB:Print("Unknown element. Use /mb reset all or a valid element id.")
                return
            end
            MB.FrameManager:ResetPosition(requested)
            MB:Print(string.format("Position reset for %s.", requested))
            return
        end

        if command == "resetstyle" then
            local requested = (arg and arg ~= "") and arg:lower() or "all"
            if requested ~= "all" and not normalizeElement(requested) then
                MB:Print("Unknown element. Use /mb resetstyle all or a valid element id.")
                return
            end
            MB.FrameManager:ResetStyle(requested)
            MB:Print(string.format("Style reset for %s.", requested))
            return
        end

        printHelp()
    end
end
