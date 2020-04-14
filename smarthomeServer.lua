--Configuration below
os.loadAPI("lib/tracking.lua")
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

local function handleCommand(sid, msg, ptc)
    --TODO actions
end

local function handleRecurring()
     --TODO scan for the players, do stuff if they violate certain boundaries
end

local function resetTimer(time)
    timer = os.startTimer(time)
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
