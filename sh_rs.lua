local rsside = "top"
local rednetside = "front"
local protocol = "sh-item"
local rsDefault = false

rs.setOutput(rsside, rsDefault)
ostate = 0
state = 0
rednet.open(rednetside)
while true do
    if rednet.isOpen(rednetside) == false then
        rednet.open(rednetside)
    end
    sid, msg, ptc = rednet.receive(protocol, 10)
    if msg == "activate" then
        state = 1
    elseif msg == "deactivate" then
        state = 0
    elseif msg == "oactivate" then
        ostate = 1
    elseif msg == "odeactivate" then
        ostate = 2
    elseif msg == "orevoke" then
        ostate = 0
    end
    local aa = rsDefault
    if ostate == 0 and state == 1 then
        aa = not rsDefault
    elseif ostate == 1 then
        aa = not rsDefault
    end
    rs.setOutput(rsside, aa)
end
