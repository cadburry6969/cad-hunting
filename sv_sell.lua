--============================
--   SELLING CONFIG
--============================
local sellanimals = {        
    ["meatdeer"]  = 140,
    ["meatpig"] = 50,
    ["meatboar"] = 120,
    ["meatlion"] = 222, 
    ["meatcow"] = 32,  
    ["meatcoyote"] = 170, 
    ["meatrabbit"] = 80, 
    ["meatbird"] = math.random(70,75), 
}
--============================
--   SELLING EVENTS
--============================
RegisterServerEvent('hunting:server:sellmeat')
AddEventHandler('hunting:server:sellmeat', function()
    local src = source        
    local Player = QBCore.Functions.GetPlayer(src)    
    local price = 0
	if Player ~= nil then
        if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
            for k, v in pairs(Player.PlayerData.items) do 
                if Player.PlayerData.items[k] ~= nil then 
                    if sellanimals[Player.PlayerData.items[k].name] ~= nil then 
                        price = price + (sellanimals[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                        Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                    end
                end
            end
            Citizen.Wait(2000)   
            Player.Functions.AddMoney("cash", price, "sold-items-hunting")
            TriggerClientEvent('QBCore:Notify', src, "You have sold your items and recieved $"..price)
        else
            TriggerClientEvent('QBCore:Notify', src, "You don't have items")
        end
	end
    Wait(10)
end)
