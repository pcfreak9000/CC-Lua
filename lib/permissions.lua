local groups = {}
local groupMemberships = {}

os.loadAPI("lib/util.lua")

function serialize(fileprefix)
    util.writeTableToFile(fileprefix.."_groups", groups)
    util.writeTableToFile(fileprefix.."_gMembers", groupMemberships)
end

function deserialize(fileprefix)
    groups = util.readTableFromFile(fileprefix.."_groups") or {}
    groupMemberships = util.readTableFromFile(fileprefix.."_gMembers") or {}
end

function listGroups(id)
    if groupMemberships[id] ~= nil then
        return groupMemberships[id]
    end
    return nil
end

function listPermissions(group)
    if groups[group] ~= nil then
        return groups[group]
    end
    return nil
end

function printPermissions(group)
    local g = listPermissions(group)
    if g ~= nil then
        print("Permissions of the group "..group)
        for k,v in pairs(g) do
            print(v)
        end
    else
        print("The group "..group.." has no permissions")
    end
end

function printGroups(id)
    local g = listGroups(id)
    if g ~= nil then
        print("Groups of the member "..id)
        for k,v in pairs(g) do
            print(v)
        end
    else
        print("The member "..id.." has no groups")
    end
end
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
