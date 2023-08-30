local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")


local config = module("doorslocktool", "config")

-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(config['ToggleCommand'],function(source,args,rawCommand)
	if GlobalState[source] then
		TriggerClientEvent("doorslocktool:Toggle",source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDHEX COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(config['AddHexCommand'],function(source,args,rawCommand)
	if GlobalState[source] and args[1] then
		if not config['AllowedSteamHex'][args[1]] then
			config['AllowedSteamHex'][args[1]] = true
			TriggerClientEvent("doorslocktool:notify",source,config['AddHexText']..' '.. args[1])
		else
			config['AllowedSteamHex'][args[1]] = false
			TriggerClientEvent("doorslocktool:notify",source,config['RemHexText']..' '.. args[1])
		end
		refreshAllowed()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REFRESHALLOWED
-----------------------------------------------------------------------------------------------------------------------------------------
function refreshAllowed()
	for _,player in pairs(GetPlayers()) do
		for k,v in pairs(GetPlayerIdentifiers(player)) do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				if config['AllowedSteamHex'][v:sub(7)] then
					GlobalState[player] = true
				else
					GlobalState[player] = false
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVETOFILE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("doorslocktool:saveToFile")
AddEventHandler("doorslocktool:saveToFile",function(data)
	if GlobalState[source] then
		if data then
			local file = io.open(GetResourcePath(GetCurrentResourceName())..'/'..config['FileName'], 'a')
			if file then
				file:write('\n'..data)
				io.close(file)
				print('^2'..string.upper(GetCurrentResourceName())..'^0: '..config['SavedFileText']..' '..GetResourcePath(GetCurrentResourceName())..'/'..config['FileName'])
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEALLOWED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("doorslocktool:updateAllowed")
AddEventHandler("doorslocktool:updateAllowed",function()
	for k,v in pairs(GetPlayerIdentifiers(source)) do
		  if string.sub(v, 1, string.len("steam:")) == "steam:" then
			if config['AllowedSteamHex'][v:sub(7)] then
				GlobalState[source] = true
			else
				GlobalState[source] = false
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTART
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  print('^2'..resourceName..' ^0UNITY: '..'^6SCRIPT EM FUNCIONAMENTO!^0')
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('playerDropped', function(reason)
	GlobalState[source] = false
end)