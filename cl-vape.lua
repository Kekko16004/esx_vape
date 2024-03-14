ESX = exports['es_extended']:getSharedObject()

local IsPlayerAbleToVape = false
local VapeMod = nil
local lastUseTime = 0
local isVaping = false

RegisterNetEvent("KmF_vape:StartVape")
AddEventHandler("KmF_vape:StartVape", function()
	IsPlayerAbleToVape = true
	local ped = GetPlayerPed(-1)
	local ad = "anim@heists@humane_labs@finale@keycards"
	local anim = "ped_a_enter_loop"

	while (not HasAnimDictLoaded(ad)) do
		RequestAnimDict(ad)
		Wait(1)
	end
	TaskPlayAnim(ped, ad, anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)

	local x,y,z = table.unpack(GetEntityCoords(ped))
	local prop_name = "ba_prop_battle_vape_01"
	VapeMod = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(VapeMod, ped, GetPedBoneIndex(ped, 18905), 0.08, -0.00, 0.03, -150.0, 90.0, -10.0, true, true, false, true, 1, true)

	Citizen.CreateThread(function()
		while IsPlayerAbleToVape do
			Citizen.Wait(5)
			if IsPlayerFreeAiming(PlayerId()) then
				print("You can't aim while vaping")
				ForceStopVape()
			end
			if IsControlJustPressed(0, Config.DragControl) then
				local currentTime = GetGameTimer()
					lastVapeTime = currentTime
					ESX.TriggerServerCallback('KmF_vape:CanVape', function(cb)
						if cb then
								local currentTime = GetGameTimer()

		
								if currentTime - lastUseTime < Config.TimeBeetweenVape then
									ESX.ShowNotification("Devi aspettare prima di poter svapare di nuovo")
									return
								end
		
								lastUseTime = currentTime
								lastVapeTime = currentTime
								-- print("Vaping")

								local ped = GetPlayerPed(-1)
								local PedPos = GetEntityCoords(ped)
								local ad = "mp_player_inteat@burger"
								local anim = "mp_player_int_eat_burger"
								if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
									while (not HasAnimDictLoaded(ad)) do
										RequestAnimDict(ad)
										Wait(1)
									end
									
									TaskPlayAnim(ped, ad, anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
									TriggerServerEvent("eff_smokes", PedToNet(ped))
									isVaping = true
									Citizen.CreateThread(function()
										Wait(Config.VapeHangTime)
										isVaping = false
										TriggerServerEvent("KmF_vape:ConsumeLiquid")
										-- TriggerEvent('esx_status:remove', 'stress', math.random(25000, 35000))
									end)
								end
						else
							ESX.ShowNotification("Non hai liquido nella tua svapo")
							-- print("No liquid")
							StopVape()
						end
					end)
			elseif IsControlJustPressed(0, Config.StopVapeControl) then
				StopVape()
			end
			BeginTextCommandDisplayHelp("STRING")
			AddTextComponentSubstringPlayerName("~INPUT_CONTEXT~ per usare ~INPUT_VEH_DUCK~ per metterla via")
			EndTextCommandDisplayHelp(0, false, true, -1)
		end
	end)
end)


RegisterNetEvent("c_eff_smokes")
AddEventHandler("c_eff_smokes", function(c_ped)
    if DoesEntityExist(NetToPed(c_ped)) and not IsEntityDead(NetToPed(c_ped)) then
        UseParticleFxAssetNextCall("core")
        StartParticleFxLoopedOnEntityBone("exp_grd_bzgas_smoke", NetToPed(c_ped), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(NetToPed(c_ped), 20279), Config.SmokeSize, 0.0, 0.0, 0.0)
		-- SetParticleFxLoopedColour(NetToPed(c_ped), 0.0, 1.0, 0.0, 0.0)
        Wait(Config.VapeHangTime)
        RemoveParticleFxFromEntity(NetToPed(c_ped))
    end
end)

function ForceStopVape()
	local ped = GetPlayerPed(-1)
	local ad = "anim@heists@humane_labs@finale@keycards"
	local anim = "ped_a_exit_loop"

	while (not HasAnimDictLoaded(ad)) do
		RequestAnimDict(ad)
		Wait(1)
	end
	TaskPlayAnim(ped, ad, anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
	DeleteEntity(VapeMod)

	for k, v in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(PlayerPedId(), v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
    end
	IsPlayerAbleToVape = false
	isVaping = false
end

function StopVape()
	if not isVaping then
		-- print("Stopping Vape")
		local ped = GetPlayerPed(-1)
		local ad = "anim@heists@humane_labs@finale@keycards"
		local anim = "ped_a_exit_loop"

		while (not HasAnimDictLoaded(ad)) do
			RequestAnimDict(ad)
			Wait(1)
		end
		TaskPlayAnim(ped, ad, anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
		DeleteEntity(VapeMod)

		for k, v in pairs(GetGamePool('CObject')) do
			if IsEntityAttachedToEntity(PlayerPedId(), v) then
				SetEntityAsMissionEntity(v, true, true)
				DeleteObject(v)
				DeleteEntity(v)
			end
		end
		IsPlayerAbleToVape = false
	else
		local ped = GetPlayerPed(-1)
		local PedPos = GetEntityCoords(ped)
		local ad = "mp_player_inteat@burger"
		local anim = "mp_player_int_eat_burger"
		if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
			while (not HasAnimDictLoaded(ad)) do
				RequestAnimDict(ad)
				Wait(1)
			end	
			TaskPlayAnim(ped, ad, anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
		end
		-- TaskPlayAnim(ped, ad, "mp_player_int_eat_exit_burger", 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
		print("You can't stop vaping")
	end
end

RegisterNetEvent("KmF_vape:StopVape")
AddEventHandler("KmF_vape:StopVape", function()
	StopVape()
end)

