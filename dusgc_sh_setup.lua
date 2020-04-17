os.loadAPI("sh_setup.lua")
os.loadAPI("permissions.lua")

permissions.addPermission("admin", "doors.dMainTop")
permissions.addPermission("admin", "doors.dMainLow")
permissions.addPermission("admin", "doors.dGarden")

permissions.addMembership("admin", "pcfreak9000")
 
pos1 = vector.new(2841, 94, -257)
pos2 = vector.new(2843, 95, -260)
registerCollider("dMainLow", collider.newBox(pos1,pos2))
pos1 = vector.new(2858, 102, -248)
pos2 = vector.new(2860, 103, -251)
registerCollider("dMainTop", collider.newBox(pos1,pos2))
pos1 = vector.new(2843, 94, -246)
pos2 = vector.new(2842, 95, -249)
registerCollider("dGarden", collider.newBox(pos1,pos2))

registerHandler("dMainTop", "doors", "4", "doors.dMainTop")
registerHandler("dMainLow", "doors", "3", "doors.dMainLow")
registerHandler("dGarden", "doors", "10", "doors.dGarden")

finish()
