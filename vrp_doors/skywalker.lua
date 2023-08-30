local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRPN = {}
Tunnel.bindInterface("vrp_doors",vRPN)
Proxy.addInterface("vrp_doors",vRPN)

local idgens = Tools.newIDGenerator()
local cfg = module("vrp_doors","config/config")
local pick = {}
local blips = {}

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		TriggerClientEvent('vrpdoorsystem:load',source,cfg.list)
	end
end)

RegisterServerEvent('vrpdoorsystem:open')
AddEventHandler('vrpdoorsystem:open',function(id)
	local source = source
	local user_id = vRP.getUserId(source)
	if cfg.list[id].block == true then
		cfg.list[id].lock = cfg.list[id].lock
	else
		if vRP.hasPermission(user_id,cfg.list[id].perm) or vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"owner.permissao") then
			vRPclient.playAnim(source,true,{{"anim@mp_player_intmenu@key_fob@","fob_click"}},false)
			cfg.list[id].lock = not cfg.list[id].lock
			TriggerClientEvent('vrpdoorsystem:statusSend',-1,id,cfg.list[id].lock)
			if cfg.list[id].sound == true then
				TriggerClientEvent("vrp_sound:source",source,'unity_doors',0.5)
			end
			if cfg.list[id].other ~= nil then
				local idsecond = cfg.list[id].other
				cfg.list[idsecond].lock = cfg.list[id].lock
				TriggerClientEvent('vrpdoorsystem:statusSend',-1,idsecond,cfg.list[id].lock)
			end
			SetTimeout(1000,function()
				vRPclient._stopAnim(source,false)
			end)
		end
	end
end)

function vRPN.forceOpen(id)
	local source = source
	local user_id = vRP.getUserId(source)
	if timers[id] == 0 or not timers[id] then
		timers[id] = 120
		TriggerClientEvent('vrpdoorsystem:statusSend',-1,id,false)
		if cfg.list[id].other ~= nil then
			if vRP.getInventoryItemAmount(user_id,"lockpick") >= 1 and vRP.tryGetInventoryItem(user_id,"lockpick",1) then
				local idsecond = cfg.list[id].other
				cfg.list[idsecond].lock = cfg.list[id].lock
				TriggerClientEvent('vrpdoorsystem:statusSend',-1,idsecond,false)

				local policia = vRP.getUsersByPermission("policia.permissao")
				local x,y,z = vRPclient.getPosition(source)

				for k,v in pairs(policia) do
					local player = vRP.getUserSource(parseInt(v))
					if player then
						async(function()
							local id = idgens:gen()
							vRPclient._playSound(player,"CONFIRM_BEEP","HUD_MINI_GAME_SOUNDSET")
							TriggerClientEvent('chatMessage',player,"911",{64,64,255},"Alarme de estabelecimento disparando.")
							pick[id] = vRPclient.addBlip(player,x,y,z,10,1,"Ocorrência",0.5,false)
							SetTimeout(20000,function() vRPclient.removeBlip(player,pick[id]) idgens:free(id) end)
						end)
					end
				end
			end
		end
	end
end