ESX = exports['es_extended']:getSharedObject()

ESX.RegisterUsableItem('vape', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('KmF_vape:StartVape', source)
end)

for k, v in pairs(Config.Flavors) do
	ESX.RegisterUsableItem(v, function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		local itemeta = xPlayer.getInventoryItem("vape")
		if itemeta then
			itemeta.info.fill = 100
			xPlayer.setInventoryItem("vape", 1, itemeta.info)
			xPlayer.removeInventoryItem(v, 1)
			TriggerClientEvent("esx:showNotification", source, "Hai riempito la tua svapo al 100%")
		end
	end)
end

RegisterServerEvent("eff_smokes")

AddEventHandler("eff_smokes", function(entity)
	TriggerClientEvent("c_eff_smokes", -1, entity)
end)

RegisterServerEvent("KmF_vape:ConsumeLiquid")
AddEventHandler("KmF_vape:ConsumeLiquid", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local itemeta = xPlayer.getInventoryItem("vape")
	-- print(json.encode(itemeta.info.fill))
	itemeta.info.quality = itemeta.info.quality - 2
	itemeta.info.fill = itemeta.info.fill - 10
	xPlayer.setInventoryItem("vape", 1, itemeta.info)
end)

ESX.RegisterServerCallback('KmF_vape:CanVape', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local itemeta = xPlayer.getInventoryItem("vape")
	if itemeta.info.fill then
		if itemeta.info.fill >= 10 then
			cb(true)
			-- print("Can vape")
		else
			cb(false)
			-- print("Can't vape")
		end
	else
		cb(false)
		-- print("Can't vape")
	end
	-- print(json.encode(itemeta.info.fill))
end)

-- RegisterCommand('givevape', function(source, args, raw)
-- 	local xPlayer = ESX.GetPlayerFromId(source)
-- 	xPlayer.addInventoryItem("vape", 1, {fill = 100, quality = 100})
-- end, false)
