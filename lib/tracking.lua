periLoc = {}
sensorAmount = 4
peris = {}

sensorDistance = 0 --4
posCenter = nil --vector.new(2831, 94, -255)
periLoc.center = "" --"bottom"
periLoc.up = "" --"playerSensor_2"
periLoc.north = "" --"playerSensor_4"
periLoc.west = "" --"playerSensor_3"

local function wrapSensors()
    for k,v in pairs(periLoc) do
        peris[k] = peripheral.wrap(v)
    end
end
 
local function getPlayersInRange(scanRange)
    local players = {}
    for k,v in pairs(peris) do
        local peri = peris[k]
        local tab = peri.getNearbyPlayers(scanRange)
        for l,b in pairs(tab) do
            if players[b.player] == nil then
                players[b.player] = 0
            end
            players[b.player] = players[b.player] + 1
        end
    end
    for k,v in pairs(players) do
        if not v == sensorAmount then
           players[k] = nil
        end
    end
    return players
end

function setSensorLocation(side, name)
    periLoc[side] = name
end

function setSensorDistance(distance)
    sensorDistance = distance
end

function setPositionOfCenterV(vectorIn)
    posCenter = vectorIn
end

function setPositionOfCenter(x,y,z)
    setPositionOfCenterV(vector.new(x,y,z))
end

function initialize()
    wrapSensors()
end

function getPlayerPositions(scanRange)
    local players = getPlayersInRange(scanRange)
    for pl,num in pairs(players) do
        if num ~= nil then                      
            local sensorData = {}
            for k,v in pairs(peris) do
                local peri = peris[k]
                local tab = peri.getNearbyPlayers(scanRange)
                for index, content in pairs(tab) do
                    if  content.player == pl then
                        sensorData[k] = content.distance
                        break
                    end
                end
            end
            local r1 = sensorData.center * sensorData.center
            local r2 = sensorData.west * sensorData.west
            local r3 = sensorData.up * sensorData.up
            local r4 = sensorData.north * sensorData.north
            local x = (r1 - r2 + sensorDistance * sensorDistance) / (2 * sensorDistance)
            local y = (r1 - r3 + sensorDistance * sensorDistance) / (2 * sensorDistance)
            local z = (r1 - r4 + sensorDistance * sensorDistance) / (2 * sensorDistance)
            --Direction corrections
            x = -x
            z = -z
            --to World coordinates
            x = x + posCenter.x
            y = y + posCenter.y
            z = z + posCenter.z
            players[pl] = vector.new(x,y,z)
        end
    end
    return players
end
 
function getPlayerDistances(scanRange)
    local pe = peris.center
    local tab = pe.getNearbyPlayers(scaneRange)
    local result = {}
    for k,v in pairs(tab) do
        result[v.player] = v.distance
    end
    return result
end
 
function printPlayerDistances(scanRange)
    local oink = getPlayerDistances(scanRange)
    for k,v in pairs(oink) do
        print(k..": "..v)
    end
end
 
function printPlayerPositions(scanRange)
    local oink = getPlayerPositions(scanRange)
    for k,v in pairs(oink) do
        print(k..": "..v.x.." "..v.y.." "..v.z)
    end
end
