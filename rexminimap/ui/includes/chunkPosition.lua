local function round(n)
	if n % 1 > 0.5 then
		return math.ceil(n)
	end
	return math.floor(n)
end

chunkSize = {40,40}
chunkScale = 1.0

function chunkPosition(pos)
    return {round(pos[1] / chunkSize[1] * chunkScale), round(pos[2] / chunkSize[2] * chunkScale)}
end

function positionChunk(pos)
    return {pos[1] * chunkSize[1] * chunkScale, pos[2] * chunkSize[2] * chunkScale}
end