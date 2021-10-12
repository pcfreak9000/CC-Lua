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

local function string.startsWith(str, start)
   return str:sub(1, #start) == start
end

local function string.endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function splitArgs(stringIn, sep)
    sep = sep or "%s"
    local t={}
    local temp = ""
    local intemp = false
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        if string.startsWith(str, "\"") then
            if not intemp then                
                intemp = true
            end 
        end
        if intemp then
            temp = temp..str
            if string.endsWith(str, "\"") and not string.endsWith(str, "\\\"") then
                intemp = false
                table.insert(t, temp)
                temp = ""
            end
        else
            table.insert(t, str)
        end
    end
    return t
end
