--[[
  Author: Panzer1119
  
  Date: Edited 26 Jun 2018 - 01:33 PM
  
  Original Source: https://github.com/Panzer1119/CCUtils/blob/master/shell_server.lua
  
  Direct Download: https://raw.githubusercontent.com/Panzer1119/CCUtils/master/shell_server.lua
]]--

os.loadAPI("lib/utils.lua")
os.loadAPI("lib/rednet_utils.lua")

args = {...}

protocol = "ss"
hostname = "shell_server"

whitelist = {programs = {}, computers = {}}
blacklist = {programs = {}, computers = {}}

file_name_whitelist = "shell_server/whitelist.lon"
file_name_blacklist = "shell_server/blacklist.lon"

--[[

Example whitelist file:

###########

{
	programs = {"id"},
	computers = {
					{
						id = 1,
						programs = {"mkdir"}
					},
					{
						id = 2,
						programs = {"ls"}
					}
				}
}

###########



Example blacklist file:

###########

{
	programs = {"exec", "lua"},
	computers = {
					{
						id = 3,
						programs = {"mkdir", "ls"}
					},
					{
						id = 5,
						programs = {}
					}
	
				}
}


###########


]]--

function reloadLists()
	if (fs.exists(file_name_whitelist)) then
		whitelist = utils.readTableFromFile(file_name_whitelist)
	else
		whitelist = {programs = {}, computers = {}}
	end
	if (fs.exists(file_name_blacklist)) then
		blacklist = utils.readTableFromFile(file_name_blacklist)
	else
		blacklist = {programs = {}, computers = {}}
	end
end

function getId(entry)
	if (entry ~= nil) then
		return entry.id
	else
		return nil
	end
end

function input(sid, msg, ptc)
	local program = msg.program
	if (program ~= nil) then
		local arguments = (msg.arguments == nil) and "" or msg.arguments
		local id_response = msg.responseId
		print("Program call from " .. sid .. ": " .. program)
		if (arguments ~= "") then
			print("With arguments: " .. arguments)
		end
		print("1")
		print("1 whitelist = " .. textutils.serialise(whitelist) .. ", blacklist = " .. textutils.serialise(blacklist))
		local computer_whitelist = utils.getTableFromArray(whitelist, sid, getId)
		print("2")
		print("2 computer_whitelist = " .. textutils.serialise(computer_whitelist))
		local computer_blacklist = utils.getTableFromArray(blacklist, sid, getId)
		print("3")
		print("3 computer_blacklist = " .. textutils.serialise(computer_blacklist))
		local isOnGlobalBlacklist = (blacklist == nil or blacklist.programs == nil or #blacklist.programs == 0) and false or utils.arrayContains(blacklist.programs, program)
		print("4")
		--print("4 isOnGlobalBlacklist = " .. isOnGlobalBlacklist)
		local isOnGlobalWhitelist = (whitelist == nil or whitelist.programs == nil or #whitelist.programs == 0) and true or utils.arrayContains(whitelist.programs, program)
		print("5")
		--print("5 isOnGlobalWhitelist = " .. isOnGlobalWhitelist)
		--[[
		if (computer_blacklist ~= nil) then
			print("5.1")
			if (computer_blacklist.programs ~= nil) then
				print("5.2")
				if (#computer_blacklist.programs >= 0) then
					print("5.3")
				end
			end
		end
		]]--
		local isOnLocalBlacklist = false
		local isOnLocalWhitelist = false
		--[[
		local isOnLocalBlacklist = (computer_blacklist == nil) and false or ((computer_blacklist.programs == nil) and false or ((#computer_blacklist.programs == 0) and false or utils.arrayContains(computer_blacklist.programs, program)))
		print("6")
		print("6 isOnLocalBlacklist = " .. isOnLocalBlacklist)
		local isOnLocalWhitelist = (computer_whitelist == nil or computer_whitelist.programs == nil or #computer_whitelist.programs == 0) and true or utils.arrayContains(computer_whitelist.programs, program)
		print("7")
		print("7 isOnLocalWhitelist = " .. isOnLocalWhitelist)
		]]--
		if (not isOnLocalBlacklist and (isOnLocalWhitelist or (not isOnGlobalBlacklist and isOnGlobalWhitelist))) then
			local exec = program .. ((arguments ~= "" and " " .. arguments or ""))
			print("Computer will exec: \"" .. exec .. "\"")
			local success = pcall(shell.run, exec)
			print("Program call from " .. sid .. " was successful: " .. success)
			sleep(0.1)
			rednet.send(sid, {responseId = id_response, success = success, extra = nil}, ptc)
		else
			print("Program call from " .. sid .. " was rejected")
			sleep(0.1)
			rednet.send(sid, {responseId = id_response, success = false, extra = "Program is blocked for you"}, ptc)
		end
		print("")
	end
end

reloadLists()

if (#args >= 1 and args[1] ~= nil) then
	protocol = args[1]
	if (#args >= 2 and args[2] ~= nil) then
		hostname = args[2]
	end
end

utils.clear()
print("Program started")
local side_modem = rednet_utils.openFirstModemFound()
print(utils.getRunningProgram(shell) .. " openend " .. side_modem .. " modem")
rednet.host(protocol, hostname)
print("Started hosting Protocol: " .. protocol .. ", Hostname: " .. hostname)

while true do
	local sid, msg, ptc = rednet.receive(protocol)
	if ((#blacklist == 0 or not utils.arrayContains(blacklist, sid)) and (#whitelist == 0 or utils.tableArrayContains(whitelist, sid, getId))) then
		pcall(input, sid, msg, ptc)
	else
		sleep(0.1)
		rednet.send(sid, {responseId = msg.responseId, success = false, extra = "Access denied"}, ptc)
	end
end

rednet.unhost(protocol, hostname)
print("Stopped hosting Protocol: " .. protocol .. ", Hostname: " .. hostname)

print("")

if (side_modem ~= nil) then
	rednet.close(side_modem)
end
print(utils.getRunningProgram(shell) .. " closed " .. side_modem .. " modem")
print("Program stopped")