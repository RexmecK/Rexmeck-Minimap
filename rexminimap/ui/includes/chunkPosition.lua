local function round(n)
	if n % 1 > 0.5 then
		return math.ceil(n)
	end
	return math.floor(n)
end

chunkSize = {40,40}

function chunkPosition(pos)
    return {round(pos[1] / chunkSize[1]), round(pos[2] / chunkSize[2])}
end

function positionChunk(pos)
    return {pos[1] * chunkSize[1], pos[2] * chunkSize[2]}
end