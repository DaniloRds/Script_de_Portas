config = {
	AllowedSteamHex = { -- FiveM, HEX : https://steamid.pro/steam-user-search
		['110000112ff7070'] = true -- substitua "110000xxxxxxxxx" por sua SteamHex
	},
	ToggleCommand = 'gd', -- nome do comando a ser executado | Padrão: /gd | Get Doors
	AddHexCommand = 'gdhex', -- -- /gdhex 110000xxxxxxxxx | concede/remove permissão temporária a um SteamHex
	SavedFileText = 'Arquivo salvo em:', -- Exibe no Console CFX do servidor
	UpdateFileText = '~y~Arquivo atualizado!',
	EnabledText = 'Doors Lock: ~g~ON',
	DisabledText = 'Doors Lock: ~r~OFF',
	AddHexText = 'Permissão ~g~concedida~w~ a',
	RemHexText = 'Permissão ~r~removida~w~ de',
	FileName = 'doors.lua',
	Keyboard = true, -- TRUE/FALSE para poder ativar/desativar por tecla.
	KeyOpen = 81, -- TECLA para ativar/desativar. APERTE O . PARA ATIVAR/DESATIVAR
	CountFrom = 0 -- Numera em ordem crescente da lista de objetos capturados para a tabela do script "doors", ex: [1],[2],[3]...
}

return config