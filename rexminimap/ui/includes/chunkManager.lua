include "chunk"
include "chunkPosition"
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
		local wrapx = chunkPosition(world.xwrap(positionChunk({x, 0})))[1]
		for y=self.view[1][2], self.view[2][2] do

			if self.finalRenderedMap[wrapx..","..y] then -- local render
				table.insert(
					pack, 
					{
						image = self.finalRenderedMap[wrapx..","..y],
						position = {x*chunkSize[1], y*chunkSize[2]}
					}
				)
			elseif self.useWorldProperties and world.getProperty("RexRadar"..chunkSize[1].."x"..chunkSize[2].."_"..wrapx..","..y) then --baked render
				local p = world.getProperty("RexRadar"..chunkSize[1].."x"..chunkSize[2].."_"..wrapx..","..y)

				if type(p) == "string" and utf8.sub(p,1,string.len("/rexradar/"..chunkSize[1].."x"..chunkSize[2]..".png")) == "/rexradar/"..chunkSize[1].."x"..chunkSize[2]..".png" then
					table.insert(
						pack, 
						{
							image = p,
							position = {x*chunkSize[1], y*chunkSize[2]}
						}
					)
				end
			elseif self.earlyRenderedMap[wrapx..","..y] then --render progress
				table.insert(pack, 
					{
						square = self.earlyRenderedMap[wrapx..","..y],
						position = {x*chunkSize[1], y*chunkSize[2]},
						size = chunkSize
					}
				)
			end

		end
	end
	return pack
end

function chunkManager:clear()
	self.map = {}
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
		local wrapx = chunkPosition(world.xwrap(positionChunk({x, 0})))[1]
		for y=self.view[1][2], self.view[2][2] do
			if not self.map[wrapx..","..y] then
				self:newChunk({wrapx,y})
			end
			used[wrapx..","..y] = true 
			local status = self.map[wrapx..","..y].coroutine:status()
			if status == "finished" then
				local result = self.map[wrapx..","..y].coroutine:result()
				if result then
					self.finalRenderedMap[wrapx..","..y] = result
					if self.useWorldProperties then
						world.setProperty("RexRadar"..chunkSize[1].."x"..chunkSize[2].."_"..wrapx..","..y, result)
					end
				end
				self.map[wrapx..","..y].coroutine:resume()
			elseif status == "suspended" then
				self.earlyRenderedMap[wrapx..","..y] = compactHexString(self.map[wrapx..","..y].chunk.pcolor)
				self.map[wrapx..","..y].coroutine:resume()
			elseif status == "dead" then -- if sometimes happens we need to crash to find errors
				self.map[wrapx..","..y].chunk:scan()
			end
		end
	end

	for i,v in pairs(self.map) do
		if not used[i] then
			self.map[i] = nil
		end
	end
end