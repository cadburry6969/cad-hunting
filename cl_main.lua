--============================
--    CLIENT CONFIGS
--============================
local lastAnimals = {}
local animals = {
    {model = "a_c_deer", hash = -664053099, item = "Deer Horns", id = 35},
    {model = "a_c_pig", hash = -1323586730, item = "Pig Pelt", id = 36},
    {model = "a_c_boar", hash = -832573324, item = "Boar Tusks", id = 37},
    {model = "a_c_mtlion",hash = 307287994,item = "Coager Claws",id = 38},
    {model = "a_c_cow", hash = -50684386, item = "Cow Pelt", id = 39},
    {model = "a_c_coyote", hash = 1682622302, item = "Coyote Pelt", id = 40},
    {model = "a_c_rabbit_01", hash = -541762431, item = "Rabbit Fur", id = 41},
    {model = "a_c_pigeon", hash = 111281960, item = "Bird Feather", id = 42},
    {model = "a_c_seagull", hash = -745300483, item = "Bird Feather", id = 43}
}
local SellSpots = {
    {x = -390.522, y = 6050.458, z = 31.500}
    -- {x = -390.522, y = 6050.458, z = 31.500}
}
local isPressed = false
--============================
--      FUNCTIONS
--============================
function SellingBlips()
    for _, v in pairs(SellSpots) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 141)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 49)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Sell Meat")
        EndTextCommandSetBlipName(blip)
    end
end

function getAnimalMatch(hash)
    for _, v in pairs(animals) do if (v.hash == hash) then return v end end
end

function removeEntity(entity)
    local delidx = 0

    for i = 1, #lastAnimals do
        if (lastAnimals[i].entity == entity) then delidx = i end
    end

    if (delidx > 0) then table.remove(lastAnimals, delidx) end
end

function lastAnimalExists(entity)
    for _, v in pairs(lastAnimals) do
        if (v.entity == entity) then return true end
    end
end

function handleDecorator(animal)
    if (DecorExistOn(animal, "lastshot")) then
        DecorSetInt(animal, "lastshot", GetPlayerServerId(PlayerId()))
    else
        DecorRegister("lastshot", 3)
        DecorSetInt(animal, "lastshot", GetPlayerServerId(PlayerId()))
    end
end

function isKillMine(animal)
    if (DecorExistOn(animal, "lastshot")) then
        local aid = DecorGetInt(animal, "lastshot")
        local id = GetPlayerServerId(PlayerId())

        return aid == id
    end
end

function drawTxt(text)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.32, 0.32)
    SetTextColour(0, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.93)
end

function ShowHelpMsg(msg)	
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)	
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

--============================
--   KILLING & SELLING
--============================
Citizen.CreateThread(function()
    SellingBlips()    
    while true do
        Citizen.Wait(4)
        local ped = PlayerPedId()              
        if (IsAimCamActive()) and not IsPedInAnyVehicle(ped, false) then
            local _, ent = GetEntityPlayerIsFreeAimingAt(PlayerId(),Citizen.ReturnResultAnyway())
            if (ent and not IsEntityDead(ent)) then
                if (IsEntityAPed(ent)) then
                    local model = GetEntityModel(ent)
                    local animal = getAnimalMatch(model)
                    if (model and animal) then
                        handleDecorator(ent)
                        if (not lastAnimalExists(ent)) then
                            if (#lastAnimals > 10) then
                                table.remove(lastAnimals, 1)
                            end
                            local newAnim = {}
                            newAnim.entity = ent
                            newAnim.data = animal
                            table.insert(lastAnimals, newAnim)
                        end
                    end
                end
            end
        end   
        if (#lastAnimals > 0) then
            for _, v in pairs(lastAnimals) do
                local pos = GetEntityCoords(ped)
                local rpos = GetEntityCoords(v.entity)
                if (GetDistanceBetweenCoords(pos, rpos.x, rpos.y, rpos.z, true) < 40 and isKillMine(v.entity)) then
                    if (DoesEntityExist(v.entity)) then
                        if (IsEntityDead(v.entity)) then                        
                            DrawMarker(20, rpos.x, rpos.y, rpos.z + 0.8, 0, 0, 0,0, 0, 0, 0.5, 0.5, -0.25, 255, 60, 60, 150, 1, 1, 2, 0, 0, 0, 0)
                            if (GetDistanceBetweenCoords(pos, rpos.x, rpos.y,rpos.z, true) < 1.1) then                                
                                ShowHelpMsg('Press ~INPUT_PICKUP~ to Harvest Animal.')
                                if IsControlJustPressed(0, 38) and not isPressed then
                                    QBCore.Functions.TriggerCallback("QBCore:HasItem", function(hasitem)                                    
                                        if hasitem then
                                            loadAnimDict('amb@medic@standing@kneel@base')
                                            loadAnimDict('anim@gangops@facility@servers@bodysearch@')
                                            TaskPlayAnim(GetPlayerPed(-1),"amb@medic@standing@kneel@base","base", 8.0, -8.0, -1, 1, 0,false, false, false)
                                            TaskPlayAnim(GetPlayerPed(-1),"anim@gangops@facility@servers@bodysearch@","player_search", 8.0, -8.0, -1,48, 0, false, false, false)                                                
                                            isPressed = true
                                            QBCore.Functions.Progressbar("harv_anim", "Harvesting Animal", 5000, false, false, {
                                                disableMovement = true,
                                                disableCarMovement = false,
                                                disableMouse = false,
                                                disableCombat = true,
                                            }, {}, {}, {}, function() 
                                                ClearPedTasks(GetPlayerPed(-1))                                                                                                
                                                TriggerServerEvent('cad-hunting:server:AddItem',v.data.id, 1)   
                                                Citizen.Wait(100)                                                                             
                                                DeleteEntity(v.entity)
                                                removeEntity(v.entity)                                                
                                                isPressed = false
                                            end)                                            
                                        else
                                            QBCore.Functions.Notify("You dont have knife.")
                                        end
                                    end, "weapon_knife")
                                end
                            end
                        end
                    else                        
                        DeleteEntity(v.entity)
                        removeEntity(v.entity)
                    end
                end
            end
        end

        for _, v in pairs(SellSpots) do
            local pos = GetEntityCoords(ped)
            if #(vector3(pos.x, pos.y, pos.z)-vector3(v.x, v.y, v.z)) < 8 then
                DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5,-0.25, 255, 60, 60, 150, 1, 1, 2, 0, 0, 0, 0)
                if #(vector3(pos.x, pos.y, pos.z)-vector3(v.x, v.y, v.z)) < 2 then                    
                    ShowHelpMsg('Press ~INPUT_PICKUP~ to Sell Hunting Items.')
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('cad-hunting:server:sellmeat')
                    end
                end
            end
        end     
    end
end)

--============================
--      Spawning Ped
--============================
RegisterNetEvent('cad-hunting:client:spawnanim')
AddEventHandler('cad-hunting:client:spawnanim', function(model)
	model           = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local forward   = GetEntityForwardVector(playerPed)
	local x, y, z   = table.unpack(coords + forward * 1.0)

	Citizen.CreateThread(function()
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(1)
		end
		CreatePed(5, model, x, y, z, 0.0, true, false)
	end)
end)
