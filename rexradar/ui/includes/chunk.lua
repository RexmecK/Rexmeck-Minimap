include "stringUtils"
include "imageColor"
include "materialUtils"
include "chunkPosition"

chunk = {}
chunk.position = {0,0}
chunk.pcolor = {0,0,0} -- progress color
chunk.blockSpeed = 1

local function _lerpColor3(from, to, s)
    return {
        from[1] + (to[1] - from[1]) * s,
        from[2] + (to[2] - from[2]) * s,
        from[3] + (to[3] - from[3]) * s,
    }
end

function chunk:new()
    local newchunk = {}
    for i,v in pairs(self) do
        newchunk[i] = v
    end
    return newchunk
end

local function getBlockColor(position) 
    local mat = world.material(position, "foreground")

    -- region not loaded
    if type(mat) == "nil" then 
        return nil, "notloaded"
    end

    -- foreground mod
    local mod = world.mod(position, "foreground")
    if type(mod) == "string" then 
        local color = modColor(mod)
        if color then
            return color, "foreground"
        end
    end

    -- foregound
    if type(mat) == "string" then 
        local color = materialColor(mat)
        if color then
            return color, "foreground"
        end
    end

    --liquid foreground
    local liquid = world.liquidAt(position)
    if liquid then --liquid
        local color = liquidColor(liquid[1])
        if color then
            return color, "foreground"
        end
    end

    --background mod
    local bgmod = world.mod(position, "background")
    if type(bgmod) == "string" then
        local color = modColor(bgmod)
        if color then
            return color, "background"
        end
    end

    --background
    local bgmat = world.material(position, "background")
    if type(bgmat) == "string" then
        local color = materialColor(bgmat)
        if color then
            return color, "background"
        end
    end
end

function chunk:setBlockSpeed(speed)
    self.blockSpeed = speed
end

function chunk:scan() --returns a image path with directives
    local offset = positionChunk(self.position)
    local image = "/rexradar/32x32.png"
    local palettes = ""
    local l = 0
    for x=1,32 do 
        for y=1,32 do
            local matoffset = {offset[1] + x - 0.5, offset[2] + y - 0.5}
            local color, type = getBlockColor(matoffset)
            
            if type == "notloaded" then
                return
            end

            if color then
                if type == "background" then
                    color = {color[1] * 0.5, color[2] * 0.5, color[3] * 0.5, 255}
                end
                palettes = palettes..";"..compactHexString({x - 1, 0, y - 1, 1}).."="..compactHexString(color)
                self.pcolor = _lerpColor3(self.pcolor, color, 1/32)
                self.pcolor[4] = math.floor(255 * (x/32))
            end

            if l >= self.blockSpeed then
                l = 0
                pcall(coroutine.yield) -- if its a coroutine we stop to let the game run
            else
                l = l + 1
            end
        end
    end
    if palettes ~= "" then
        image = image.."?replace"..palettes
    end
    return image
end