os.loadAPI("cryptoNet")


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
    print("Enter command: ")
    local cmd = read()
    cryptoNet.send(socket, textutils.serialize({typ="command", cmd=cmd}))
end

function onStart()
--    print("Enter server address: ")
--    local addr = read()
    local socket = cryptoNet.connect("pcfreak9000.de")
    promptLogin(socket)    
end

loggedIn = false

function onEvent(event)
    if event[1] == "login_failed" then
        loggedIn = false
        print("Login failed. Try again:")
        promptLogin(event.socket)
    elseif event[1] == "login" then
        loggedIn = true
        print("Login successful.")
        promptCommand(event.socket)
    elseif event[1] == "logout" then
        loggedIn = false
        print("Logged out.")
        promptLogin(event.socket)
    elseif event[1] == "encrypted_message" then
        local table = textutils.unserialize(event[2])
        if table.typ == "print" then
            print(table.msg)
        elseif table.typ == "execute_lua" then
            loadstring(table.func)
        else
            print("Received message with unknown type: "..table.typ)
        end
        if loggedIn then
            promptCommand(event.socket)
        end
    elseif event[1] == "connection_closed" then
        loggedIn = false
        print("Connection terminated.")
    elseif event[1] == "connection_opened" then
        print("Connection opened.")
    end
end

cryptoNet.setLoggingEnabled(false)
cryptoNet.startEventLoop(onStart, onEvent)
