RegisterCommand("delgun", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "CS-Delgun") then
        TriggerClientEvent("delgun:toggle", source)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Delgun", "You do not have permission to use this command."}
        })
    end
end, false)

RegisterCommand("delmenu", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "CS-Delgun") then
        TriggerClientEvent("delmenu:toggle", source)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Delmenu", "You do not have permission to use this command."}
        })
    end
end, false)
