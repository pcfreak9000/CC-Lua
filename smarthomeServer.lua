--Configuration below
os.loadAPI("lib/tracking.lua")
os.loadAPI("lib/collider.lua")
os.loadAPI("lib/util.lua")
os.loadAPI("lib/permissions.lua")
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
datafileprefix = "data/sms"
--Configuration above

--Events: activated, deactivated, oactivated, odeactivated, orevoke

--key=colName, value=collider
local registeredColliders = {}

--key=colName, value={key=index, value=player}
local occupiedColliders = {}

--key=colName, value={key=index, value={prog, ui, perm}}
local registeredHandlers = {}

local running = 1

local function deserialize()
    registeredColliders = util.readTableFromFile(datafileprefix.."_colliders") or {}
    registeredHandlers = util.readTableFromFile(datafileprefix.."_handlers") or {}
    permissions.deserialize(datafileprefix)
end

--init start
print("Initializing...")
tracking.initialize()
deserialize()
--init end

local function serialize()
    util.writeTableToFile(datafileprefix.."_colliders", registeredColliders)
    util.writeTableToFile(datafileprefix.."_handlers", registeredHandlers)
    permissions.serialize(datafileprefix)
end

local function registerHandler(colName, program, uniqueInfo, permission)
    local data = {prog=program, ui=uniqueInfo, perm=permission or ""}
    if registeredHandlers[colName] == nil then
        registeredHandlers[colName] = {}
    end
    table.insert(registeredHandlers[colName], data)
    serialize()
end

local function registerCollider(name, coll)
    registeredColliders[name] = coll
    serialize()
end

local function handleCommand(sid, msg, ptc)
    --TODO actions
    if msg[1] == "server" then
        table.remove(msg, 1)
        if #msg == 0 then
            return {code=2}
        elseif msg[1] == "ping" then
            return {code=3, ans="pong"}
        elseif msg[1] == "remote" then
            table.remove(msg, 1)
            if #msg == 0 then
                return {code=2}
            elseif msg[1] == "stop" then
                print("Remote server-stop initiated by SID "..sid)
                running = 0
                return {code=3, ans="Initiated remote server-stop..."}
            elseif msg[1] == "reboot" then
                running = 2
                return {code=3, ans="Initiated remote reboot..."}
            elseif msg[1] == "shutdown" then
                running = 3
                return {code=3, ans="Initiated remote shutdown..."}
            end
        end
    elseif msg[1] == "override" then
        --TODO override
    end
    return {code=4}
end

local function triggerEvent(colName, evType, player, pos)
    local handlers = registeredHandlers[colName]
    if handlers ~= nil then
        for i,data in pairs(handlers) do
            local permission = data.perm
            if permission == "" or permissions.hasPermission(player, permission) then
                shell.run(data.prog, evType, data.ui or "", player or "")
            end
        end
    end
end

local function handleRecurring()
     local players = tracking.getPlayerPositions(positionsRange)
     --Check if anyone of the players just left any of the colliders. If so, take appropiate action
     for colName, pArray in pairs(occupiedColliders) do
        for k,pl in pairs(pArray) do
            local vec = players[pl]
            if vec == nil or not collider.isInside(registeredColliders[colName], vec) then 
                --TODO refine event
                triggerEvent(colName, "deactivate", pl, vec)
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
            if freshJoined and collider.isInside(col, ve) then
                --TODO refine event
                triggerEvent(colName, "activate", k, ve)
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

print("Starting smarthome server...")
resetTimer(0.5)
rednet.open(rednetSide)
print("Started.")
while running == 1 do
    if rednet.isOpen(rednetSide) == false then
        rednet.open(rednetSide)
        resetTimer(0.1)
        print("Reopened rednet connection.")
    end
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
                local ans = handleCommand(sid, msg, ptc)
                local repc = ans.code
                if ans.ans ~= nil and repc == 0 then
                    repc = 3
                end
                rednet.send(sid, {responsecode = repc, answer = ans.ans}, protocol)
            end
        end
    end
end
 
rednet.close(rednetSide)
print("Stopped smarthome server")
if running == 2 then
    shell.run("reboot")
elseif running == 3 then
    shell.run("shutdown")
end
