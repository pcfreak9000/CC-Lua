os.loadAPI("cryptoNet")

function onStart()
    local socket = cryptoNet.connect("pcfreak9000.de")
end

function onEvent(event)
    if event[1] == "encrypted_message" then
        print(event[2])
    end
end

cryptoNet.startEventLoop(onStart, onEvent)
