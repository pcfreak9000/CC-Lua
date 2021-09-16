os.loadAPI("cryptoNet")

loggedIn = false
promptingCmd = false

function promptLogin(socket)
    print("Enter username: ")
    local username = read()
    print("Enter password: ")
    local password = read("*")
    cryptoNet.login(socket, username, password)
    username = ""
    password = ""
end

function promptCommand(socket)
    if promptingCmd then
        return
    end
    promptingCmd = true;
    print("Enter command: ")
    local cmd = read()
    promptingCmd = false
    cryptoNet.send(socket, textutils.serialise({typ="command", cmd=cmd}))
end

function onStart()
--    print("Enter server address: ")
--    local addr = read()
    print("Connecting...")
    local socket = cryptoNet.connect("pcfreak9000.de")
    promptLogin(socket)    
end



function onEvent(event)
    if event[1] == "login_failed" then
        loggedIn = false
        print("Login failed. Try again:")
        promptLogin(event[3])
    elseif event[1] == "login" then
        loggedIn = true
        print("Login successful.")
        promptCommand(event[3])
    elseif event[1] == "logout" then
        loggedIn = false
        print("Logged out.")
        promptLogin(event[3])
    elseif event[1] == "encrypted_message" then
        local table = textutils.unserialize(event[2])
        if table == nil then
            
        elseif table.typ == "print" then
            print(table.msg)
        elseif table.typ == "execute_lua" then
            loadstring(table.func)
        else
            print("Received message with unknown type: "..table.typ)
        end
        if loggedIn then
            promptCommand(event[3])
        end
    elseif event[1] == "connection_closed" then
        loggedIn = false
        print("Connection terminated.")
    elseif event[1] == "connection_opened" then
        print("Connection opened.")
    elseif event[1] == "terminate" then
        cryptoNet.close(event[3])
    end
end

cryptoNet.setLoggingEnabled(false)
cryptoNet.startEventLoop(onStart, onEvent)
