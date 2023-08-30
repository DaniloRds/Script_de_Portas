local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vRPNserver = Tunnel.getInterface("vrp_doors")
local cfg = module("vrp_doors","config/config")
local doors = {}
local hour = 0


RegisterNetEvent('vrpdoorsystem:load')
AddEventHandler('vrpdoorsystem:load',function(list)
	doors = list
end)

RegisterNetEvent('vrpdoorsystem:statusSend')
AddEventHandler('vrpdoorsystem:statusSend',function(i,status)
	if i ~= nil and status ~= nil then
		doors[i].lock = status
	end
end)

function searchIdDoor()
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	for k,v in pairs(doors) do
		if GetDistanceBetweenCoords(x,y,z,v.x,v.y,v.z,true) <= 1.5 then
			return k
		end
	end
	return 0
end

RegisterNetEvent('vrpdoorsystem:forceOpen')
AddEventHandler('vrpdoorsystem:forceOpen',function(name)
	local publicId = searchPublicIdDoor()
	if publicId ~= 0 then
		vRP._playAnim(true,{{"veh@mower@base","start_engine"}},true)
		TriggerEvent("progress",15000,"Destrancando")
		TriggerEvent("itensNotify","usar","Usou",""..name.."")
		SetTimeout(15000,function()
			vRPNserver.forceOpen(publicId)
			vRP._stopAnim(false)
		end)
	end
end)

Citizen.CreateThread(function()
	while true do
		local idle = 500
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))

			local id = searchIdDoor()
			if id ~= 0 then
					if IsControlJustPressed(0,38) then
						-- vRP._playAnim(true,{{"veh@mower@base","start_engine"}},false)
						Citizen.Wait(500)
						TriggerServerEvent("vrpdoorsystem:open",id)
					end
			end

		
		for k,v in pairs(doors) do
			if GetDistanceBetweenCoords(x,y,z,v.x,v.y,v.z,true) <= 20 then
				idle = 5

				local door = GetClosestObjectOfType(v.x,v.y,v.z,1.0,v.hash,false,false,false)
				
				if door ~= 0 then
					SetEntityCanBeDamaged(door,false)
					if v.lock == false then
						if v.text then
							if GetDistanceBetweenCoords(x,y,z,v.x,v.y,v.z,true) <= v.distance then
								--DrawText3Ds(v.x,v.y,v.z+0.2,"[~p~E~w~] Porta ~p~destrancada~w~.")
								drawTxt('[~g~E~w~] PORTA DESTRANCADA',2,0.45,0.9,0.40,255,255,255,180)
							end
						end
						NetworkRequestControlOfEntity(door)
						FreezeEntityPosition(door,false)
					else
						local lock,heading = GetStateOfClosestDoorOfType(v.hash,v.x,v.y,v.z,lock,heading)
						if heading > -0.02 and heading < 0.02 then
							if v.text then
								if GetDistanceBetweenCoords(x,y,z,v.x,v.y,v.z,true) <= v.distance then
									--DrawText3Ds(v.x,v.y,v.z+0.2,"[~p~E~w~] Porta ~p~trancada~w~.")
									drawTxt('[~r~E~w~] PORTA TRANCADA',2,0.45,0.9,0.45,255,255,255,180)
								end
							end
							NetworkRequestControlOfEntity(door)
							FreezeEntityPosition(door,true)
						end
					end
				end
			end
		end
		Citizen.Wait(idle)
	end
end)

function DrawText3Ds(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.30,0.30)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)

	DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0115, 0.001+factor, 0.03, 0, 0, 0,80)
end

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end