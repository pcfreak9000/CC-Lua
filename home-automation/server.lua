local serverAddress = "pcfreak9000.de"
local serverModuleNames = {}

os.loadAPI("cryptoNet")
os.loadAPI("util")

function handleCommand(socket, cmd)
    local cmdtab = util.splitArgs(cmd)
    print(textutils.serialize(cmdtab))
    -- check if any module has a cmd 
end

function onStart()
    cryptoNet.host(serverAddress)
end

function onEvent(event)
    if event[1] == "encrypted_message" then
        local socket = event[3]
        if socket.username ~= nil then
            local received = event[2]
            if received.typ ~= nil then
                if received.typ == "command" then
                    local ok = pcall(handleCommand, socket, received.cmd)
                    if not ok then
                        local tosend = {typ="print", msg="500 Internal Server Error"}
                        cryptoNet.send(socket, tosend)
                    end
                end
            else
                -- a message without type information came in
                local tosend = {typ="print", msg="400 Bad Request"}
                cryptoNet.send(socket, tosend)
            end
        else
            -- the user isn't logged in
            local tosend = {typ="print", msg="401 Unauthorized"}
            cryptoNet.send(socket, tosend)
        end
    end
end


cryptoNet.startEventLoop(onStart, onEvent)



-- Add functionality directly to this server
-- Add clients for functions
