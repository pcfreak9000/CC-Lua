function invertTable(table)
    local result = {}
    for k,v in pairs(table) do
        result[v] = k
    end
    return result
end

function tableContains(element, table)
    for k,v in pairs(table) do
        if v == element then
            return true
        end
    end 
    return false
end

function tableRemoveElement(ptable, element)
    for k,v in pairs(ptable) do
        if v == element then
            table.remove(ptable, k)
            return
        end
    end
end
