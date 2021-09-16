os.loadAPI("cryptoNet")

function onStart()
    local socket = cryptoNet.connect("pcfreak9000.de")
end

function onEvent(event)
    
end

cryptoNet.startEventLoop(onStart, onEvent)
