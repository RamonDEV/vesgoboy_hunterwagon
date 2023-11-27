local OpenPrompt
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local cart = {"huntercart01"}
local cooldown = 0
local quantityToHeight = {
    [1] = 0.1,
	[2] = 0.2,
    [3] = 0.3,
	[4] = 0.4,
	[5] = 0.5,
}

Citizen.CreateThread(function()
	SetupAnimalPrompt()
	while true do 
		Citizen.Wait(1)
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local forwardoffset = GetOffsetFromEntityInWorldCoords(ped, 2.0, 2.0, 0.0)
		local Pos2 = GetEntityCoords(ped)
		local targetPos = GetOffsetFromEntityInWorldCoords(obj3, -0.0, 1.1,-0.1)
		local rayCast = StartShapeTestRay(Pos2.x, Pos2.y, Pos2.z, forwardoffset.x, forwardoffset.y, forwardoffset.z,-1,ped,7)
		local A,hit,C,C,spot = GetShapeTestResult(rayCast)                
		local model = GetEntityModel(spot)
		local cartcoords = GetEntityCoords(spot)

		for _,carts in pairs(cart) do
			if model == GetHashKey(carts) then
				local animal = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
				local cartnetwork = NetworkGetNetworkIdFromEntity(spot)
				if animal then
					local looted = Citizen.InvokeNative(0x8DE41E9902E85756, animal)
					local animalmodel = GetEntityModel(animal)
					local animalnetwork = NetworkGetNetworkIdFromEntity(animal)
					local pano = Citizen.InvokeNative(0x7264F9CA87A9830B, spot)

					if not pano then
						Citizen.InvokeNative(0x75F90E4051CC084C, spot, GetHashKey("pg_mp005_huntingWagonTarp01"))
					end

					if cooldown == 0 then
						for _,b in pairs(peds_list) do
							if animalmodel == _ then
								local label  = CreateVarString(10, 'LITERAL_STRING', "Colocar Carcaça")
								PromptSetActiveGroupThisFrame(PromptGroup, label)
								if Citizen.InvokeNative(0xC92AC953F0A982AE,OpenPrompt) then
									cooldown = 300
									startCooldown()
									Citizen.InvokeNative(0xC7F0B43DCDC57E3D, PlayerPedId(), animal, GetEntityCoords(PlayerPedId()), 10.0, true)
									DoScreenFadeOut(1800)
									Wait(2000)
									TriggerServerEvent('vesgoboy_hunterwagon:teleportentitysv', cartnetwork, animalmodel, looted, animalnetwork)
									DoScreenFadeIn(3000)
									Wait(2000)
								end
							end
						end
					end
				else
					local label  = CreateVarString(10, 'LITERAL_STRING', "Retirar Carcaça")
					PromptSetActiveGroupThisFrame(PromptGroup, label)
					if Citizen.InvokeNative(0xC92AC953F0A982AE,OpenPrompt) then
						cooldown = 300
						startCooldown()
						TriggerServerEvent("vesgoboy_hunterwagon:removecarcass", cartnetwork)
					end
				end
			end
		end
	end
end)

RegisterNetEvent('vesgoboy_hunterwagon:deleteped')
AddEventHandler('vesgoboy_hunterwagon:deleteped', function(animalnetwork)
	local animalped = NetworkGetEntityFromNetworkId(animalnetwork)
	DeleteEntity(animalped)
end)

RegisterNetEvent('vesgoboy_hunterwagon:tarp')
AddEventHandler('vesgoboy_hunterwagon:tarp', function(cartnetwork,quantity)
	local cart = NetworkGetEntityFromNetworkId(cartnetwork)
	local heightquantity = quantityToHeight[quantity] or 0.0
	if quantity >= 5 then
		heightquantity = 0.5
	end
    Citizen.InvokeNative(0x31F343383F19C987, cart, heightquantity, 1)
end)

RegisterNetEvent('vesgoboy_hunterwagon:carcass')
AddEventHandler('vesgoboy_hunterwagon:carcass', function(model,looted,metapeoutfit)
	local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.-1, 0.0)) --get coords front of player
	local creature = CreatePed(model,x,y,z,GetEntityHeading(PlayerPedId()), true, true, false, false)
	SetEntityHealth(creature,0,nil)
	SetEntityAlpha(creature,0)
	Citizen.InvokeNative(0x502EC17B1BED4BFA,PlayerPedId(),creature)
	Citizen.InvokeNative(0x283978A15512B2FE,creature, true)
	if looted then
		Citizen.InvokeNative(0x6BCF5F3D8FFE988D,creature,looted)
	end
	SetEntityAlpha(creature,255)
end)

function SetupAnimalPrompt()
    Citizen.CreateThread(function()
        local str = 'Carroça de Caça'
        OpenPrompt = PromptRegisterBegin()
        PromptSetControlAction(OpenPrompt, 0x760A9C6F) -- G
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(OpenPrompt, str)
        PromptSetEnabled(OpenPrompt, 1)
        PromptSetVisible(OpenPrompt, 1)
		PromptSetStandardMode(OpenPrompt, 1)
		PromptSetGroup(OpenPrompt, PromptGroup)
		PromptRegisterEnd(OpenPrompt)
    end)
end

function startCooldown()
    Citizen.CreateThread(function()
        while cooldown > 0 do
            Wait(0)
            cooldown = cooldown - 1
        end
    end)
end