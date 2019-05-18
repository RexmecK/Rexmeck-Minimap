include "chunk"
include "stringUtils"
include "utf8"
include "uCoroutine"

chunkManager = {}
chunkManager.view = {{1,1}, {2,2}}
chunkManager.map = {}
chunkManager.finalRenderedMap = {}
chunkManager.earlyRenderedMap = {}
chunkManager.useWorldProperties = true

function chunkManager:new()
    local n = {}
    for i,v in pairs(self) do
        n[i] = v
    end
    return n
end

function chunkManager:newChunk(cp)
    local n = {}
    n.chunk = chunk:new()
    n.chunk.position = cp
    n.coroutine = uCoroutine:new(function() return n.chunk:scan() end)
    self.map[cp[1]..","..cp[2]] = n
end

function chunkManager:getView()
    local pack = {}
    for x=self.view[1][1], self.view[2][1] do
        for y=self.view[1][2], self.view[2][2] do
            if self.finalRenderedMap[x..","..y] then
                table.insert(pack, {image = self.finalRenderedMap[x..","..y], position = {x*32, y*32}})
            elseif self.useWorldProperties and world.getProperty("RexRadar_"..x..","..y) then
                local p = world.getProperty("RexRadar_"..x..","..y)
                if type(p) == "string" and utf8.sub(p,1,19) == "/rexradar/32x32.png" then
                    table.insert(pack, {image = p, position = {x*32, y*32}})
                end
            elseif self.earlyRenderedMap[x..","..y] then
                table.insert(pack, {square = self.earlyRenderedMap[x..","..y], position = {x*32, y*32}})
            end
        end
    end
    return pack
end

function chunkManager:clear()
    self.map[x..","..y] = {}
    self.finalRenderedMap = {}
end

function chunkManager:setBlockSpeed(speed)
    for i,v in pairs(self.map) do
        chunk.blockSpeed = speed
        self.map[i]:setBlockSpeed(speed)
    end
end

function chunkManager:update(dt)
    self.earlyRenderedMap = {}
    local used = {}
    for x=self.view[1][1], self.view[2][1] do
        for y=self.view[1][2], self.view[2][2] do
            if not self.map[x..","..y] then
                self:newChunk({x,y})
            end
            used[x..","..y] = true 
            local status = self.map[x..","..y].coroutine:status()
            if status == "finished" then
                local result = self.map[x..","..y].coroutine:result()
                if result then
                    self.finalRenderedMap[x..","..y] = result
                    if self.useWorldProperties then
                        world.setProperty("RexRadar_"..x..","..y, result)
                    end
                end
                self.map[x..","..y].coroutine:resume()
            elseif status == "suspended" then
                self.earlyRenderedMap[x..","..y] = compactHexString(self.map[x..","..y].chunk.pcolor)
                self.map[x..","..y].coroutine:resume()
            elseif status == "dead" then -- if sometimes happens we need to crash to find errors
                self.map[x..","..y].chunk:scan()
            end
        end
    end

    for i,v in pairs(self.map) do
        if not used[i] then
            self.map[i] = nil
        end
    end
end