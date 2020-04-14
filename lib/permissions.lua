local groups = {}
local groupMemberships = {}

os.loadAPI("lib/util.lua")

function hasPermission(id, perm)
    if groupMemberships[id] ~= nil then
        local grs = groupMemberships[id]
        for k,v in pairs(grs) do
            local grt = groups[v]
            return util.tableContains(perm, grt)
        end
    end
    return false
end

function addPermission(group, perm)
    if groups[group] == nil then
        groups[group] = {}
    end
    table.insert(groups[group], perm)
end

function removePermission(group, perm)
    if groups[group] == nil then
        return
    end
    util.tableRemoveElement(groups[group], perm)
end

function addMembership(group, id)
    if groupMemberships[id] == nil then
        groupMemberships[id] = {}
    end
    table.insert(groupMemberships[id], group)
end

function removeMembership(group, id)
    if groupMemberships[id] == nil then
        return
    end
     util.tableRemoveElement(groupMemberships[id], group)
end
