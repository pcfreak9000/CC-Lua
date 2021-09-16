os.loadApPI("cryptoNet")

function onStart()
    cryptoNet.host("pcfreak9000.de")
end

function onEvent(event)
    if event[1] == "connection_opened" then
        local socet = event[2]
        cryptoNet.send(socket, "Hello there!")
    end
end

cryptoNet.startEventLoop()
