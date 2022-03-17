-- Configuration START
local serverAddress = "pcfreak9000.de"
local serverModuleFiles = {}
-- Configuration END

os.loadAPI("cryptoNet")
os.loadAPI("util")
os.loadAPI("perms")

local modulesLoaded = {}
local commands = {}
--local currentModuleName = nil

-- Command stuff

function addCommand(name, runner, plvl) then
    plvl = plvl or 1
    commands[name] = {id=currentModuleName, runner=runner, plvl=plvl}
end

-- Module stuff

function loadModules()
    print("Loading modules...")
    for i,v in ipairs(serverModuleFiles) do
        local ok, ret = pcall(dofile, v)
        if ok and ret.id ~= nil then
            -- TODO maybe check if the id is valid?
            modulesLoaded[ret.id] = ret
            print("Loaded module '"..v.."'/'"..ret.id.."'")
        else
            print("Could not load module '"..v.."'")
        end
    end
    print("Loaded "..#modulesLoaded.." modules")
end

function setupModules()
    local setupfunctionstable = {addCommand=addCommand}
    for n,v in pairs(modulesLoaded) do
        currentModuleName = n
        local func = v.setup;
        if func ~= nil then
            func(setupfunctionstable)
        end 
        currentModuleName = nil
    end
end

-- Handling event stuff etc below

function sendError(socket, text)
    local tosend = {typ="print", msg=text}
    cryptoNet.send(socket, tosend)
    cryptoNet.send(socket, {typ="prompt"})
end

function handleCommand(socket, cmd)
    local cmdtab = util.splitArgs(cmd)
    -- find command
    local cmdid = cmdtab[1]
    local cmdinfo = commands[cmdid]
    if cmdinfo ~= nil then
        -- check permissions
        local user = socket.username
        local permstring = cmdinfo.id..".command.".cmdid
        if perms.hasPermission(user, permstring) and socket.permissionLevel >= cmdinfo.plvl then
            --TODO use pcall
            local ok, ret = pcall(cmdinfo.runner, cmdtab)
            if not ok then
                sendError(socket, "500 Internal Server Error")
                print("An error occured while executing a command: "..ret)
            end
        else
            sendError(socket, "403 Forbidden")
        end
    else
        sendError(socket, "404 Not Found")
    end
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
                    handleCommand(socket, received.cmd)
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
