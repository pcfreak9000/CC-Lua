args = { ... }
rednet.open("back")
if args[2] == nil then
    args[2] = "white"
end
rednet.send(21, {msg=args[1], color=colors[args[2]:lower()]},"news")
rednet.close()
