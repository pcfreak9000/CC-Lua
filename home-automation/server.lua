-- Configuration START
local serverAddress = "pcfreak9000.de"
local serverModuleFiles = {}
-- Configuration END

os.loadAPI("cryptoNet")
os.loadAPI("util")

local modulesLoaded = {}
local commandRunners = {}

function loadModules()
    print("Loading modules...")
    for i,v in ipairs(serverModuleFiles) do
        local ok, ret = pcall(dofile, v)
        if ok then
            table.insert(modulesLoaded, ret)
            print("Loaded module '"..v.."'")
        else
            print("Could not load module '"..v.."'")
        end
    end
    print("Loaded "..#modulesLoaded.." modules")
end

function setupModules()
    for i,v in ipairs(modulesLoaded) do
        local func = v.setup;
        if func ~= nil then
            func()
        end 
    end
end

-- Handling event stuff etc below

function handleCommand(socket, cmd)
    local cmdtab = util.splitArgs(cmd)
    for i=1, #cmdtab do 
        print(i .. ": " .. cmdtab[i])
    end
    cryptoNet.send(socket, {typ="prompt"})
    -- check if any module has a cmd 
end

function sendError(socket, text)
    local tosend = {typ="print", msg=text}
    cryptoNet.send(socket, tosend)
    cryptoNet.send(socket, {typ="prompt"})
end

-- Event stuff below

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
                    local ok, errmsg = pcall(handleCommand, socket, received.cmd)
                    if not ok then
                        sendError(socket, "500 Internal Server Error")
                        print("An error occured while handling a command: "..errmsg)
                    end
                end
            else
                -- a message without type information came in
                sendError(socket, "400 Bad request")
                print("Received a message without type information")
            end
        else
            -- the user isn't logged in
            local tosend = {typ="print", msg="401 Unauthorized"}
            cryptoNet.send(socket, tosend)
        end
    end
end

loadModules()
--setupCore()
setupModules()
cryptoNet.startEventLoop(onStart, onEvent)



-- Add functionality directly to this server
-- Add clients for functions
