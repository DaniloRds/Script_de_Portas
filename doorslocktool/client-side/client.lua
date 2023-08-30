local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local config = module("doorslocktool","config")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local active = false
local count = config['CountFrom']

Citizen.CreateThread(function()
    while config['Keyboard'] do
      Citizen.Wait(5)
      if IsControlJustPressed(0,config['KeyOpen']) then
        TriggerEvent("doorslocktool:Toggle")
      end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION
-----------------------------------------------------------------------------------------------------------------------------------------
local funct = function()
	CreateThread(function()
		while true do
		Wait(1)
			if active then
				DisableControlAction(0,24, true) -- disable attack
				DisableControlAction(0,25, true) -- disable aim
				DisableControlAction(0, 1, true) -- LookLeftRight
				DisableControlAction(0, 2, true) -- LookUpDown

				local _,cds,obj = screenToWorld(18, false)

				if DoesEntityExist(obj) then
					drawEntityBox(obj, 30,170,0,145)
					DrawText3Ds(cds, "Model: "..GetEntityModel(obj))
					
					if IsDisabledControlJustReleased(2, 237) then
						count = count + 1
						local x,y,z = table.unpack(math.floor(GetEntityCoords(obj)))
						local model = GetEntityModel(obj)
						local data = '['..count..'] = { ["x"] = '..x..', ["y"] = '..y..', ["z"] = '..z..', ["hash"] = '..model..', ["lock"] = true, ["text"] = true, ["distance"] = 1.4, ["block"] = false, ["perm"] = "SuaPerm", ["sound"] = true },'
						TriggerServerEvent("doorslocktool:saveToFile",data)
						Notify(config['UpdateFileText'])
                        TriggerEvent("Notify","sucesso","Porta atualizada com sucesso! ID: [ "..count.." ] HASH: [ "..model.." ]",5000)
					end
				end
			else
				break
			end
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("doorslocktool:Toggle")
AddEventHandler("doorslocktool:Toggle",function()

	if not GlobalState[GetPlayerServerId(PlayerId())] then
		return
	end
	
	if not active then
		active = true
		funct()
		EnterCursorMode()
		SetCursorLocation(0.5,0.5)
		Notify(config['EnabledText'])
	else
		LeaveCursorMode()
		active = false
		Notify(config['DisabledText'])
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
function Notify(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent("doorslocktool:notify")
AddEventHandler("doorslocktool:notify",function(msg)
	Notify(msg)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)

	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
  
	if active then
		LeaveCursorMode()
		Notify(config['DisabledText'])
	end
	
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTART
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onClientResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	
	TriggerServerEvent("doorslocktool:updateAllowed")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function mulNumber(vector1, value)
    local result = {}
    result.x = vector1.x * value
    result.y = vector1.y * value
    result.z = vector1.z * value
    return result
end

-- Add one vector to another.
function addVector3(vector1, vector2) 
    return {x = vector1.x + vector2.x, y = vector1.y + vector2.y, z = vector1.z + vector2.z}   
end

-- Subtract one vector from another.
function subVector3(vector1, vector2) 
    return {x = vector1.x - vector2.x, y = vector1.y - vector2.y, z = vector1.z - vector2.z}
end

function rotationToDirection(rotation) 
    local z = degToRad(rotation.z)
    local x = degToRad(rotation.x)
    local num = math.abs(math.cos(x))

    local result = {}
    result.x = -math.sin(z) * num
    result.y = math.cos(z) * num
    result.z = math.sin(x)
    return result
end

function w2s(position)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)
    if not onScreen then
        return nil
    end

    local newPos = {}
    newPos.x = (_x - 0.5) * 2
    newPos.y = (_y - 0.5) * 2
    newPos.z = 0
    return newPos
end

function processCoordinates(x, y) 
    local screenX, screenY = GetActiveScreenResolution()

    local relativeX = 1 - (x / screenX) * 1.0 * 2
    local relativeY = 1 - (y / screenY) * 1.0 * 2

    if relativeX > 0.0 then
        relativeX = -relativeX;
    else
        relativeX = math.abs(relativeX)
    end

    if relativeY > 0.0 then
        relativeY = -relativeY
    else
        relativeY = math.abs(relativeY)
    end

    return { x = relativeX, y = relativeY }
end

function s2w(camPos, relX, relY)
    local camRot = GetGameplayCamRot(0)
    local camForward = rotationToDirection(camRot)
    local rotUp = addVector3(camRot, { x = 10, y = 0, z = 0 })
    local rotDown = addVector3(camRot, { x = -10, y = 0, z = 0 })
    local rotLeft = addVector3(camRot, { x = 0, y = 0, z = -10 })
    local rotRight = addVector3(camRot, { x = 0, y = 0, z = 10 })

    local camRight = subVector3(rotationToDirection(rotRight), rotationToDirection(rotLeft))
    local camUp = subVector3(rotationToDirection(rotUp), rotationToDirection(rotDown))

    local rollRad = -degToRad(camRot.y)
    -- print(rollRad)
    local camRightRoll = subVector3(mulNumber(camRight, math.cos(rollRad)), mulNumber(camUp, math.sin(rollRad)))
    local camUpRoll = addVector3(mulNumber(camRight, math.sin(rollRad)), mulNumber(camUp, math.cos(rollRad)))

    local point3D = addVector3(addVector3(addVector3(camPos, mulNumber(camForward, 10.0)), camRightRoll), camUpRoll)

    local point2D = w2s(point3D)

    if point2D == undefined then
        return addVector3(camPos, mulNumber(camForward, 10.0))
    end

    local point3DZero = addVector3(camPos, mulNumber(camForward, 10.0))
    local point2DZero = w2s(point3DZero)

    if point2DZero == nil then
        return addVector3(camPos, mulNumber(camForward, 10.0))
    end

    local eps = 0.001

    if math.abs(point2D.x - point2DZero.x) < eps or math.abs(point2D.y - point2DZero.y) < eps then
        return addVector3(camPos, mulNumber(camForward, 10.0))
    end

    local scaleX = (relX - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (relY - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = addVector3(addVector3(addVector3(camPos, mulNumber(camForward, 10.0)), mulNumber(camRightRoll, scaleX)), mulNumber(camUpRoll, scaleY))

    return point3Dret
end

function degToRad(deg)
    return (deg * math.pi) / 180.0
end

 -- Get entity, ground, etc. targeted by mouse position in 3D space.
function screenToWorld(flags, ignore)
    local x, y = GetNuiCursorPosition()

    local absoluteX = x
    local absoluteY = y

    local camPos = GetGameplayCamCoord()
    local processedCoords = processCoordinates(absoluteX, absoluteY)
    local target = s2w(camPos, processedCoords.x, processedCoords.y)

    local dir = subVector3(target, camPos)
    local from = addVector3(camPos, mulNumber(dir, 0.05))
    local to = addVector3(camPos, mulNumber(dir, 300))

    local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, flags, ignore, 0)
	local a, b, c, d, e = GetShapeTestResult(ray)
    return b, c, e, to
end

function drawEntityBox(entity,r,g,b,a)
    if entity then

        r = r or 255
        g = g or 0
        b = b or 0
        a = a or 40

        local model = GetEntityModel(entity)
        local min,max = GetModelDimensions(model)

        local top_front_right = GetOffsetFromEntityInWorldCoords(entity,max)
        local top_back_right = GetOffsetFromEntityInWorldCoords(entity,vector3(max.x,min.y,max.z))
        local bottom_front_right = GetOffsetFromEntityInWorldCoords(entity,vector3(max.x,max.y,min.z))
        local bottom_back_right = GetOffsetFromEntityInWorldCoords(entity,vector3(max.x,min.y,min.z))

        local top_front_left = GetOffsetFromEntityInWorldCoords(entity,vector3(min.x,max.y,max.z))
        local top_back_left = GetOffsetFromEntityInWorldCoords(entity,vector3(min.x,min.y,max.z))
        local bottom_front_left = GetOffsetFromEntityInWorldCoords(entity,vector3(min.x,max.y,min.z))
        local bottom_back_left = GetOffsetFromEntityInWorldCoords(entity,min)


        -- LINES

        -- RIGHT SIDE
        DrawLine(top_front_right,top_back_right,r,g,b,a)
        DrawLine(top_front_right,bottom_front_right,r,g,b,a)
        DrawLine(bottom_front_right,bottom_back_right,r,g,b,a)
        DrawLine(top_back_right,bottom_back_right,r,g,b,a)

        -- LEFT SIDE
        DrawLine(top_front_left,top_back_left,r,g,b,a)
        DrawLine(top_back_left,bottom_back_left,r,g,b,a)
        DrawLine(top_front_left,bottom_front_left,r,g,b,a)
        DrawLine(bottom_front_left,bottom_back_left,r,g,b,a)

        -- Connection
        DrawLine(top_front_right,top_front_left,r,g,b,a)
        DrawLine(top_back_right,top_back_left,r,g,b,a)
        DrawLine(bottom_front_left,bottom_front_right,r,g,b,a)
        DrawLine(bottom_back_left,bottom_back_right,r,g,b,a)


        -- POLYGONS

        -- FRONT
        DrawPoly(top_front_left,top_front_right,bottom_front_right,r,g,b,a)
        DrawPoly(bottom_front_right,bottom_front_left,top_front_left,r,g,b,a)

        -- TOP
        DrawPoly(top_front_right,top_front_left,top_back_right,r,g,b,a)
        DrawPoly(top_front_left,top_back_left,top_back_right,r,g,b,a)

        -- BACK
        DrawPoly(top_back_right,top_back_left,bottom_back_right,r,g,b,a)
        DrawPoly(top_back_left,bottom_back_left,bottom_back_right,r,g,b,a)

        -- LEFT
        DrawPoly(top_back_left,top_front_left,bottom_front_left,r,g,b,a)
        DrawPoly(bottom_front_left,bottom_back_left,top_back_left,r,g,b,a)

        -- RIGHT
        DrawPoly(top_front_right,top_back_right,bottom_front_right,r,g,b,a)
        DrawPoly(top_back_right,bottom_back_right,bottom_front_right,r,g,b,a)

        -- BOTTOM
        DrawPoly(bottom_front_left,bottom_front_right,bottom_back_right,r,g,b,a)
        DrawPoly(bottom_back_right,bottom_back_left,bottom_front_left,r,g,b,a)

        return true

    end
    return false
end

function DrawText3Ds(cds, text)
	local x,y,z = table.unpack(cds)
    local onScreen,_x,_y=World3dToScreen2d(x+1,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end