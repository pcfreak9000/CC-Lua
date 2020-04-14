--[[

  Author: Panzer1119
  
  Date: Edited 29 Jun 2018 - 02:28 AM
  
  Original Source: https://github.com/Panzer1119/CCUtils/blob/master/lib/su.lua
  
  Direct Download: https://raw.githubusercontent.com/Panzer1119/CCUtils/master/lib/su.lua

]]--

charset_numerical_alpha_big_alpha = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset_numerical_alpha_big_alpha, string.char(c)) end
    for c = 65, 90  do table.insert(charset_numerical_alpha_big_alpha, string.char(c)) end
    for c = 97, 122 do table.insert(charset_numerical_alpha_big_alpha, string.char(c)) end
end

charset_alpha_big_alpha = {}  do -- [a-zA-Z]
    for c = 65, 90  do table.insert(charset_alpha_big_alpha, string.char(c)) end
    for c = 97, 122 do table.insert(charset_alpha_big_alpha, string.char(c)) end
end

charset_numerical_alpha = {}  do -- [0-9a-z]
    for c = 48, 57  do table.insert(charset_numerical_alpha, string.char(c)) end
    for c = 65, 90  do table.insert(charset_numerical_alpha, string.char(c)) end
end

charset_numerical_big_alpha = {}  do -- [0-9A-Z]
    for c = 48, 57  do table.insert(charset_numerical_big_alpha, string.char(c)) end
    for c = 97, 122 do table.insert(charset_numerical_big_alpha, string.char(c)) end
end

charset_numerical = {}  do -- [0-9]
    for c = 48, 57  do table.insert(charset_numerical, string.char(c)) end
end

charset_alpha = {}  do -- [a-z]
    for c = 65, 90  do table.insert(charset_alpha, string.char(c)) end
end

charset_big_alpha = {}  do -- [A-Z]
    for c = 97, 122 do table.insert(charset_big_alpha, string.char(c)) end
end

charset_numerical_alpha_big_alpha_inverse = {}  do 
	for c = 48, 57  do charset_numerical_alpha_big_alpha_inverse[string.char(c)]=c end
	for c = 65, 90  do charset_numerical_alpha_big_alpha_inverse[string.char(c)]=c end
	for c = 97, 122 do charset_numerical_alpha_big_alpha_inverse[string.char(c)]=c end
end

function isEmpty(s)
  return s == nil or s == ''
end

function findLast(haystack, needle)
    local i = haystack:match(".*" .. needle .. "()")
    if i == nil then return nil else return i-1 end
end

function randomString(charset, length)
    if not length or length <= 0 then return '' end
	if length >= 245 then return nil end
    math.randomseed(os.clock()^5)
    return randomString(charset, length - 1) .. charset[math.random(1, #charset)]
end

function sumString(text)
	if (text == nil) then
		return nil
	end
	local sum = 0
	for c in text:gmatch"." do
		sum = sum + charset_big_alpha_numerical_inverse[c]
	end
	return sum
end