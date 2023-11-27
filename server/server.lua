RedEM = exports["redem_roleplay"]:RedEM()
local huntspace = {}

RegisterServerEvent('vesgoboy_hunterwagon:teleportentitysv')
AddEventHandler('vesgoboy_hunterwagon:teleportentitysv', function(cartnetwork, pedmodel, looted, animalnetwork)
    local _source = source

    if not huntspace[cartnetwork] then
        huntspace[cartnetwork] = {}
    end

    if #huntspace[cartnetwork] <= Config.MaxCarcass then
        table.insert(huntspace[cartnetwork], { pedmodel = pedmodel, looted = looted })
        TriggerClientEvent("vesgoboy_hunterwagon:deleteped", _source, animalnetwork)
    else
        RedEM.Functions.NotifyLeft(_source, "Carroça de Caça", "Essa Carroça já está cheia.", Config.Textures.cross[1], Config.Textures.cross[2], 4000)
    end
    
    TriggerClientEvent("vesgoboy_hunterwagon:tarp", _source,cartnetwork,#huntspace[cartnetwork])
end)

RegisterServerEvent('vesgoboy_hunterwagon:removecarcass')
AddEventHandler('vesgoboy_hunterwagon:removecarcass', function(cartnetwork)
    local _source = source
    
    if huntspace[cartnetwork] and #huntspace[cartnetwork] > 0 then
        local lastEntry = huntspace[cartnetwork][#huntspace[cartnetwork]]
        TriggerClientEvent("vesgoboy_hunterwagon:carcass",_source, lastEntry.pedmodel, lastEntry.looted)
        table.remove(huntspace[cartnetwork], #huntspace[cartnetwork])
        TriggerClientEvent("vesgoboy_hunterwagon:tarp", _source,cartnetwork,#huntspace[cartnetwork])
    else
        RedEM.Functions.NotifyLeft(_source, "Carroça de Caça", "Carroça Vazia.", Config.Textures.cross[1], Config.Textures.cross[2], 4000)
    end
end)