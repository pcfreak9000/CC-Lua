os.loadAPI("lib/permissions")
os.loadAPI("lib/util")

datafileprefix="data/sms"

--key=colName, value={key=index, value={prog, ui, perm}}
local registeredHandlers = {}

--key=colName, value=collider
local registeredColliders = {}


local function serialize()
    util.writeTableToFile(datafileprefix.."_colliders", registeredColliders)
    util.writeTableToFile(datafileprefix.."_handlers", registeredHandlers)
    permissions.serialize(datafileprefix)
end

function finish()
    serialize()
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

--TestStart
pos1 = vector.new(2841, 94, -257)
pos2 = vector.new(2843, 96, -260)
registerCollider("door1", collider.newBox(pos1,pos2))
registerHandler("door1", "doors", nil, nil)
--TestEnd
