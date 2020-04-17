local rsside = "top"
local rednetside = "front"
local protocol = "sh-item"

rednet.open(rednetside)
ostate = 0
state = 0
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
    local aa = false
    if ostate == 0 and state == 1 then
        aa = true
    elseif ostate == 1 then
        aa = true
    end
    rs.setOutput(rsside, aa)
end
