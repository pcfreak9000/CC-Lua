--Configuration below
os.loadAPI("lib/tracking.lua")
os.loadAPI("lib/collider.lua")
os.loadAPI("lib/util.lua")
tracking.setSensorDistance(4)
tracking.setPositionOfCenter(2831, 94, -255)
tracking.setSensorLocation("center", "bottom")
tracking.setSensorLocation("up", "playerSensor_2")
tracking.setSensorLocation("north", "playerSensor_4")
tracking.setSensorLocation("west", "playerSensor_3")
secretToken = "354vn786"
rednetSide = "left"
protocol = "smarthome"
checkPositions = 0.05
positionsRange = 1000
--Configuration above
tracking.initialize()

--key=colName, value=collider
local registeredColliders = {}

--key=colName, value={key=index, value=player}
local occupiedColliders = {}

--key=colName, value={key=index, value={prog, ui}}
local registeredHandlers = {}


local function handleCommand(sid, msg, ptc)
    --TODO actions
end

local function handleRecurring()
     local players = tracking.getPlayerPositions(positionsRange)
     --Check if anyone of the players just left any of the colliders. If so, take appropiate action
     for colName, pArray in pairs(occupiedColliders) do
        for k,pl in pairs(pArray) do
            local vec = players[pl]
            if vec == nil or not registeredColliders[colName]:isInside(vec) then 
                print("onDeactivate: "..pl)
                --TODO trigger onDeactivate-event
                table.remove(pArray, k)
            end
        end
     end
     --Check if anyone of the players just joined any of the colliders. If so, take appropiate action
     for k,ve in pairs(players) do
        for colName, col in pairs(registeredColliders) do
            local freshJoined = true
            if occupiedColliders[colName] ~= nil then
                freshJoined = not util.tableContains(occupiedColliders[colName], k)
            end
            if freshJoined and col:isInside(ve) then
                print("onActivate: "..k)
                --TODO trigger onActivate-event
                if occupiedColliders[colName] == nil then
                    occupiedColliders[colName] = {}
                end
                table.insert(occupiedColliders[colName], k)
            end
        end
     end
end

local function resetTimer(time)
    timer = os.startTimer(time)
end

function registerHandler(colName, program, uniqueInfo)
    local data = {prog=program, ui=uniqueInfo}
    if registeredHandlers[colName] == nil then
        registeredHandlers[colName] = {}
    end
    table.insert(registeredHandlers[colName], data)
end

function registerCollider(name, collider)
    registeredColliders[name] = collider
end

print("Starting smarthome server...")
resetTimer(0.5)
rednet.open(rednetSide)
 
while true do
   	local event, p1, p2, p3, p4, p5 = os.pullEvent()
    if event == "timer" and p1 == timer then
        handleRecurring()
        resetTimer(0.05)
	elseif event == "rednet_message" then
        local sid = p1
        local msg = p2
        local ptc = p3
        if ptc ~= protocol then
            print("SID "..sid.." used the wrong protocol to contact this server!")
        end
        --TODO: Check blacklist/whitelist
        if msg[1] ~= secretToken then
            print("SID "..sid.." tried do send something but specified the wrong token! (C: 1)")
            rednet.send(sid, {responsecode = 1}, protocol)
        else
            table.remove(msg, 1)
            if #msg == 0 then
                print("SID "..sid.." didn't specify an action! (C: 2)")
                rednet.send(sid, {responsecode = 2}, protocol)
            else
                print("SID "..sid.." made a request!")
                handleCommand(sid, msg, ptc)
                rednet.send(sid, {responsecode = 0}, protocol)
            end
        end
    end
end
 
rednet.close(rednetSide)
