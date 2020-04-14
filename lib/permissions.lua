local groups = {}
local groupMemberships = {}
local filename_suffix_groups = "_groups"
local filename_suffic_groupMemberships = "_gMembers"

os.loadAPI("lib/util.lua")

function serialize(fileprefix)
    local fg = fileprefix..filename_suffix_groups
    local fgm = fileprefix..filename_suffic_groupMemberships
    util.writeTableToFile(fg, groups)
    util.writeTableToFile(fgm, groupMemberships)
    clearGroups()
    clearMemberships()
end

function deserialize(fileprefix)
    groups = util.readTableFromFile(fileprefix.."_groups") or {}
    groupMemberships = util.readTableFromFile(fileprefix.."_gMembers") or {}
end

function clearGroups()
    groups = {}
end

function clearMemberships()
    groupMemberships = {}
end

function listGroups(id)
    if groupMemberships[id] ~= nil then
        return groupMemberships[id]
    end
    return {}
end

function listPermissions(group)
    if groups[group] ~= nil then
        return groups[group]
    end
    return {}
end

function printPermissions(group)
    local g = listPermissions(group)
    if #g > 0 then
        print("Permissions of the group "..group..":")
        for k,v in pairs(g) do
            print(" "..v)
        end
    else
        print("The group "..group.." has no permissions.")
    end
end

function printGroups(id)
    local g = listGroups(id)
    if #g > 0 then
        print("Groups of the member "..id..":")
        for k,v in pairs(g) do
            print(" "..v)
        end
    else
        print("The member "..id.." has no groups.")
    end
end

function hasPermission(id, perm)
    if groupMemberships[id] ~= nil then
        local grs = groupMemberships[id]
        for k,v in pairs(grs) do
            local grt = groups[v]
            local result = util.tableContains(grt, perm)
            if result then
                return true
            end
        end
    end
    return false
end

function addPermission(group, perm)
    if groups[group] == nil then
        groups[group] = {}
    end
    if not util.tableContains(groups[group], perm) then
        table.insert(groups[group], perm)
    end
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
    if not util.tableContains(groupMemberships[id], group) then
        table.insert(groupMemberships[id], group)
    end
end

function removeMembership(group, id)
    if groupMemberships[id] == nil then
        return
    end
     util.tableRemoveElement(groupMemberships[id], group)
end
