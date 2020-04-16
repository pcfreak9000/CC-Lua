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
--Assuming there is no message loss because that might result in an infinite loop here
while true do
    sid, msg, ptc = rednet.receive(protocol, timeout)
    if sid == serverId and ptc == protocol then
        if msg.responsecode == 0 then
            print("Server responded with code 0")
        elseif msg.responsecode == 1 then
            print("Server responded with code 1 (Access denied)")
        elseif msg.responsecode == 2 then
            print("Server responded with code 2 (Not enough arguments)")
        elseif msg.responsecode == 3 then
            print("Server responded with code 3 (Answer):")
            print(msg.answer or "No answer.")
        end
        break
    end
end
rednet.close()
