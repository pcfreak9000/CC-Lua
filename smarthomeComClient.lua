args = { ... }
--Configuration below
serverId = 5
secretToken = "354vn786"
protocol = "smarthome"
timeout = 2
--Configuration above
rednet.open("back")
table.insert(args, 1, secretToken)
rednet.send(serverId, args, protocol)
sid, msg, ptc = rednet.receive(protocol, timeout)
if sid == serverId and ptc == protocol then
    if msg.responsecode == 0 then
        print("Code 0")
    elseif msg.responsecode == 1 then
        print("Code 1 (Access denied)")
    elseif msg.responsecode == 2 then
        print("Code 2 (Not enough arguments)")
    elseif msg.responsecode == 3 then
        print("Code 3 (Answer):")
        print(msg.answer or "No answer.")
    elseif msg.responsecode == 4 then
        print("Code 4 (Program not found)")
    else
        print("Code '"..msg.responsecode.."' (Unknown)")
    end
else
    print("The server did not respond in "..timeout.." sec.")
end
rednet.close()
