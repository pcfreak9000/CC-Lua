function invertTable(table)
    local result = {}
    for k,v in pairs(table) do
        result[v] = k
    end
    return result
end

function tableContains(table, element)
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

function readAllFromFile(filename)
	if (fs.exists(filename)) then
		local f = fs.open(filename, "r")
		local all = f.readAll()
		f.close()
		return all
	else
		return nil
	end
end

function readTableFromFile(filename)
    local read = readAllFromFile(filename)
    if read == nil then
        return nil
    end
	return textutils.unserialise(read)
end

function writeAllToFile(filename, data)
	local f = fs.open(filename, "w")
	f.write(data)
	f.close()
end

function writeTableToFile(filename, table_)
	writeAllToFile(filename, textutils.serialise(table_))
end

local function startsWith(str, start)
   return str:sub(1, #start) == start
end

local function endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

-- see older commits for some basic quoting functionality
function splitArgs(stringIn, sep)
    sep = sep or "%s"
    local t={}
    for str in string.gmatch(stringIn, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end
