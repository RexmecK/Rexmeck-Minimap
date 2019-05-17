

function getPixelColor(image, position)
    local color = {0,0,0,0}
    local basecrop = "?crop;"..position[1]..";"..position[2]..";"..(position[1]+1)..";"..(position[2]+1)
    for r = 0,255 do
        local rg = root.nonEmptyRegion(image..basecrop.."?multiply=f000".."?replace="..compactHexString({r,0,0,0}).."=ffff")
		if rg then
			color[1] = r
			break
		end
	end
    for g = 0,255 do
        local rg = root.nonEmptyRegion(image..basecrop.."?multiply=0f00".."?replace="..compactHexString({0,g,0,0}).."=ffff")
		if rg then
			color[2] = g
			break
		end
	end
    for b = 0,255 do
        local rg = root.nonEmptyRegion(image..basecrop.."?multiply=00f0".."?replace="..compactHexString({0,0,b,0}).."=ffff") 
		if rg then
			color[3] = b
			break
		end
	end
    for a = 0,255 do
        local rg = root.nonEmptyRegion(image..basecrop.."?multiply=000f".."?replace="..compactHexString({0,0,0,a}).."=0000")
		if not rg then
			color[4] = a
			break
		end
    end
    return color
end

local cachedColor = {}

local function lerpColor(from, to, ratio)
	return {
		from[1] + (to[1] - from[1]) * ratio,
		from[2] + (to[2] - from[2]) * ratio,
		from[3] + (to[3] - from[3]) * ratio,
		255
	}
end

function getImageColor(image)
    if cachedColor[image] then return cachedColor[image] end
	local nonEmpty = root.nonEmptyRegion(image)
	local directives = "?crop;"..nonEmpty[1]..";"..nonEmpty[2]..";"..nonEmpty[3]..";"..nonEmpty[4]..";"
	local imageSize = root.imageSize(image..directives)
	local finalDirectives = image..directives.."?scale="..(2/imageSize[1])..";"..(2/imageSize[2])
	local imageSize2 = root.imageSize(finalDirectives)
	local color = {0,0,0,255}
	for x = 0, imageSize2[1] - 1 do
		for y = 0,imageSize2[2] - 1 do
			local getcolor = getPixelColor(finalDirectives, {x,y})
			if getcolor[1] > 0 or getcolor[2] > 0 or getcolor[3] > 0 and not (getcolor[1] == 255 and getcolor[2] == 255 and getcolor[2] == 255) then
				color = lerpColor(color, getcolor, 0.25)
			end
		end
	end
    cachedColor[image] = color
    return cachedColor[image]
end