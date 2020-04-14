--[[
  Author: Panzer1119
  
  Date: Edited 25 Jun 2018 - 07:44 PM
  
  Original Source: https://github.com/Panzer1119/CCUtils/blob/master/lib/sounds.lua
  
  Direct Download: https://raw.githubusercontent.com/Panzer1119/CCUtils/master/lib/sounds.lua
]]--

os.loadAPI("lib/utils.lua")

sounds = {}

function loadSounds(filename)
  sounds = textutils.unserialise(utils.readAllFromFile(filename))
end

function playSound(shell, soundname, source, target, place, volume, pitch, minimumVolume)
  shell.run("exec playSound " .. soundname .. " " .. source .. " " .. target .. " " .. place .. " " .. volume .. " " .. pitch .. " " .. minimumVolume)
end

function playSound(shell, soundname, source, target, place, volume, pitch)
  shell.run("exec playSound " .. soundname .. " " .. source .. " " .. target .. " " .. place .. " " .. volume .. " " .. pitch)
end

function playSound(shell, soundname, source, target, place, volume)
  shell.run("exec playSound " .. soundname .. " " .. source .. " " .. target .. " " .. place .. " " .. volume)
end

function playSound(shell, soundname, source, target, place)
  shell.run("exec playSound " .. soundname .. " " .. source .. " " .. target .. " " .. place)
end

function playSoundHere(shell, soundname, source, target)
  shell.run("exec playSound " .. soundname .. " " .. source .. " " .. target)
end

function playContinousSound(shell, soundname, source, target, place, volume)
  local sound = getSoundByName(soundname)
  local playTime = sound.length
  local pauseTime = sound.pause
  local sleepTime = playTime + pauseTime
  while true do
    playSound(shell, soundname, source, target, place, volume)
	sleep(sleepTime)
  end
end

function playSoundAndWaitForLoop(shell, soundname, source, target, place, volume)
  local sound = getSoundByName(soundname)
  local playTime = sound.length
  local pauseTime = sound.pause
  local sleepTime = playTime + pauseTime
  playSound(shell, soundname, source, target, place, volume)
  sleep(sleepTime)
end

function playSoundAndWait(shell, soundname, source, target, place, volume)
  local sound = getSoundByName(soundname)
  local playTime = sound.length
  playSound(shell, soundname, source, target, place, volume)
  sleep(playTime)
end

function getSoundByName(soundname)
  if (#sounds == 0) then
    return nil
  end
  for i = 1, #sounds do
    if (sounds[i].name == soundname) then
	  return sounds[i]
	end
  end
end