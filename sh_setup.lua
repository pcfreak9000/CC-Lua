os.loadAPI("lib/permissions.lua")
os.loadAPI("lib/util.lua")

--key=colName, value={key=index, value={prog, ui, perm}}
local registeredHandlers = {}

--key=colName, value=collider
local registeredColliders = {}

--key=com, value={alias, {prog, perm, args}}
local registeredCommands = {}

local function serialize(datafileprefix)
    util.writeTableToFile(datafileprefix.."_colliders", registeredColliders)
    util.writeTableToFile(datafileprefix.."_handlers", registeredHandlers)
    util.writeTableToFile(datafileprefix.."_commands", registeredCommands)
    permissions.serialize(datafileprefix)
end

function finishp(datafileprefix)
    serialize(datafileprefix)
    registeredHandlers = {}
    registeredColliders = {}
    registeredCommands = {}
end
 
function finish()
    finishp("data/sms")
end

function registerHandler(colName, program, uniqueInfo, permission)
    local data = {prog=program, ui=uniqueInfo, perm=permission or ""}
    if registeredHandlers[colName] == nil then
        registeredHandlers[colName] = {}
    end
    table.insert(registeredHandlers[colName], data)
    --serialize()
end

function registerCollider(name, coll)
    registeredColliders[name] = coll
    --serialize()
end

function registerCommand(alias, command, permi, ...)
    local tab = {prog=command, perm=permi, args=arg}
    registeredCommands[alias] = tab
    --serialize()
end
