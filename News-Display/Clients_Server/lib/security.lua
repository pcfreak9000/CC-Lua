--[[

  Author: Panzer1119
  
  Date: Edited 29 Jun 2018 - 09:29 PM
  
  Original Source: https://github.com/Panzer1119/CCUtils/blob/master/lib/security.lua
  
  Direct Download: https://raw.githubusercontent.com/Panzer1119/CCUtils/master/lib/security.lua

]]--

os.loadAPI("lib/utils.lua")

timeMultiplier = 100

function getFlooredTime()
	return math.floor(os.time() * timeMultiplier)
end

function genSmallMult()
    math.randomseed(os.clock()^5)
	return math.abs(math.random(300000, 1000000))
	end

function genNormalMult()
    math.randomseed(os.clock()^5)
	return math.abs(math.random(30000000000, 100000000000))
end

function genNormalMod()
    math.randomseed(os.clock()^5)
	return math.abs(math.random(300000, 1000000))
end

function genNormalKey()
	local key = {mult_1=nil, mult_2=nil, mult_3=nil, mod = nil}
	key.mult_1 = genNormalMult()
	sleep(math.random(0.4, 1))
	key.mult_2 = genNormalMult()
	sleep(math.random(0.4, 1))
	key.mult_3 = genSmallMult()
	sleep(math.random(0.4, 1))
	key.mod = genNormalMod()
	return key
end

function gen2FACode(mult_1, mult_2, mult_3, mod)
	if (mult_1 ~= nil and mult_2 ~= nil and mult_3 ~= nil and mod ~= nil) then
		return ((((getFlooredTime() * mult_1) % (os.day() * mult_3)) * mult_2) % mod)
	elseif (mult_1 ~= nil) then
		return gen2FACode(mult_1.mult_1, mult_1.mult_2, mult_1.mult_3, mult_1.mod)
	else
		return nil
	end
end

function isValid2FACode(mult_1, mult_2, mult_3, mod, code, usedCodes)
	if (mult_1 ~= nil and mult_2 ~= nil and mult_3 ~= nil and mod ~= nil and code ~= nil) then
		local code_ = gen2FACode(mult_1, mult_2, mult_3, mod)
		if (code_ ~= code) then
			return false
		else
			if (usedCodes == nil) then
				return true
			else
				if (#usedCodes == 0) then
					usedCodes[1] = code
					return true
				end
				utils.addToArray(usedCodes, code)
				return not utils.containsArray(usedCodes, code)
			end
		end
	elseif (mult_1 ~= nil and code~= nil) then
		return isValid2FACode(mult_1.mult_1, mult_1.mult_2, mult_1.mult_3, mult_1.mod, code)
	else
		return nil
	end
end