os.loadAPI("lib/utils.lua")
serverId = -1
function loadServerId()
  local temp = utils.readAllFromFile("serverId.txt")
  serverId = temp == nil and -1 or tonumber(temp)
end
mon = peripheral.find("monitor")
mon.clear()
mon.setCursorPos(1, 1)
term.redirect(mon)
--rednet.open("top")
while true do
  while not rednet.isOpen("top") do
      rednet.open("top")
  end
	 local sid, msg, ptc = rednet.receive("news")
  loadServerId()
  if ((serverId == -1 or serverId == sid) and msg and msg.msg) then
    local x, y = mon.getSize()
    if (msg.time) then
      --term.native().write(msg.time .. " ")
      if (string.len(msg.time .. " ") <= x) then
        mon.setTextColor(colors.blue)
        write(msg.time .. " ")
      end
    end
    if (msg.color) then
      mon.setTextColor(msg.color)
    else
	     mon.setTextColor(colors.white)
    end
    --term.native().print(msg.msg)
   	print(msg.msg)
	   mon.setTextColor(colors.red)
    for i=1, x do
       write("-")
    end
    print()
  end
end
rednet.close("top")
