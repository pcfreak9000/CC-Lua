local type_sphere = 0
local type_box = 1

local colliderPrefab = {
    isInside = function(self, vec)
        if self.colType == type_sphere then
            local relV = vec - self.pos
            if relV.x*relV.x + relV.y*relV.y + relV.z*relV.z <= self.radius * self.radius then
                return true
            end
            return false
        elseif self.colType == type_rect then
            if vec.x <= math.max(self.p1.x, self.p2.x) and vec.x >= math.min(self.p1.x,self.p2.x) then
                if vec.y <= math.max(self.p1.y, self.p2.y) and vec.y >= math.min(self.p1.y,self.p2.y) then
                    if vec.z <= math.max(self.p1.z, self.p2.z) and vec.z >= math.min(self.p1.z,self.p2.z) then
                        return true
                    end
                end
            end
            return false
        end
        error("incorrect type")
    end
}

local colMeta = {
    __index = colliderPrefab
}

newCircle = function(v,r)
    local col = {colType=type_sphere, pos=v, radius=r}
    setmetatable(col, colMeta)
    return col
end

newBox = function(pos1, pos2)
    local col = {colType=type_box, p1=pos1, p2=pos2}
    setmetatable(col, colMeta)
    return col
end
