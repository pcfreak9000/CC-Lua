os.loadAPI("sh_setup.lua")
os.loadAPI("lib/permissions.lua")

permissions.addPermission("admin", "doors.dMainTop")
permissions.addPermission("admin", "doors.dMainLow")
permissions.addPermission("admin", "doors.dGarden")

permissions.addMembership("admin", "pcfreak9000")
 
pos1 = vector.new(2841, 94, -257)
pos2 = vector.new(2843, 95, -260)
sh_setup.registerCollider("dMainLow", collider.newBox(pos1,pos2))
pos1 = vector.new(2858, 102, -248)
pos2 = vector.new(2860, 103, -251)
sh_setup.registerCollider("dMainTop", collider.newBox(pos1,pos2))
pos1 = vector.new(2843, 94, -246)
pos2 = vector.new(2842, 95, -249)
sh_setup.registerCollider("dGarden", collider.newBox(pos1,pos2))

sh_setup.registerHandler("dMainTop", "doors", "4", "doors.dMainTop")
sh_setup.registerHandler("dMainLow", "doors", "3", "doors.dMainLow")
sh_setup.registerHandler("dGarden", "doors", "10", "doors.dGarden")

sh_setup.finish()
