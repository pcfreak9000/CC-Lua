s = peripheral.wrap("right")

while true do
    tab = s.getNearbyPlayers(20)
    hehe = false
    for k,v in pairs(tab) do
        if v.player == "pcfreak9000" and v.distance < 2.5 then
            rs.setOutput("top", true)
            hehe = true
        end
    end
    if not hehe then 
        rs.setOutput("top", false)
    end
    sleep(0.01)
end  
    
