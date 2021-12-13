--============================
--    SERVER CONFIG
--============================
local animals = {
    [1] = {item = "meatdeer", id = 35},
    [2] = {item = "meatpig", id = 36},
    [3] = {item = "meatboar", id = 37},
    [4] = {item = "meatlion", id = 38},
    [5] = {item = "meatcow", id = 39},
    [6] = {item = "meatcoyote", id = 40},
    [7] = {item = "meatrabbit", id = 41},
    [8] = {item = "meatbird",  id = 42},
    [9] = {item = "meatbird", id = 43}
}
--============================
--       EVENTS
--============================
RegisterServerEvent("cad-hunting:server:AddItem")
AddEventHandler("cad-hunting:server:AddItem", function(data, amount)
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
    for i = 1, #animals do
        if data == animals[i].id then
            Player.Functions.AddItem(animals[i].item, amount)    
            TriggerClientEvent("inventory:client:ItemBox", _source, QBCore.Shared.Items[animals[i].item], "add")                  
        end
    end
end)

RegisterServerEvent("cad-hunting:server:spawnanimals")
AddEventHandler("cad-hunting:server:spawnanimals", function()
    local _source = source    
    TriggerClientEvent("cad-hunting:client:spawnanimals", -1)
end)

--============================
--      Spawning Ped
--============================
QBCore.Commands.Add("spawnanimal", "Spawn Animals", {{"model", "Animal Model"}}, false, function(source, args)
    TriggerClientEvent('cad-hunting:client:spawnanim', source, args[1])
end, 'god')
