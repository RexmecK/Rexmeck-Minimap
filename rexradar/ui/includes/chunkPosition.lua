local function round(n)
	if n % 1 > 0.5 then
		return math.ceil(n)
	end
	return math.floor(n)
end

function chunkPosition(pos)
    return {round(pos[1] / 32), round(pos[2] / 32)}
end

function positionChunk(pos)
    return {pos[1] * 32, pos[2] * 32}
end