include "stringUtils"
include "imageColor"
include "materialUtils"
include "chunkPosition"

chunk = {}
chunk.position = {0,0}
chunk.pcolor = {0,0,0} -- progress color
chunk.blockSpeed = 2

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

function chunk:scan() --returns a image path with directives
    local offset = positionChunk(self.position)
    local image = "/rexradar/32x32.png"
    local palettes = ""
    local l = 0
    for x=1,32 do 
        for y=1,32 do
            local matoffset = {offset[1] + x - 0.5, offset[2] + y - 0.5}
            local status, mat = pcall(world.material, matoffset, "foreground")
            local status2, liquid = pcall(world.liquidAt, matoffset)
            local status3, mod = pcall(world.mod, matoffset, "foreground")

            if status and type(mat) == "nil" then -- region not loaded
                return nil
            elseif status3 and type(mod) == "string" then
                local color = modColor(mod)
                if color and color[4] > 0 then
                    palettes = palettes..";"..compactHexString({x - 1, 0, y - 1, 1}).."="..compactHexString(color)
                    self.pcolor = _lerpColor3(self.pcolor, color, 1/20)
                    self.pcolor[4] = math.floor(255 * (x/32))
                end
            elseif status and type(mat) == "string" then
                local color = materialColor(mat)
                if color and color[4] > 0 then
                    palettes = palettes..";"..compactHexString({x - 1, 0, y - 1, 1}).."="..compactHexString(color)
                    self.pcolor = _lerpColor3(self.pcolor, color, 1/20)
                    self.pcolor[4] = math.floor(255 * (x/32))
                end
            elseif status2 and liquid then
                local color = liquidColor(liquid[1])
                if color and color[4] > 0 then
                    palettes = palettes..";"..compactHexString({x - 1, 0, y - 1, 1}).."="..compactHexString(color)
                    self.pcolor = _lerpColor3(self.pcolor, color, 1/20)
                    self.pcolor[4] = math.floor(255 * (x/32))
                end
            else
                local status, mat = pcall(world.material, matoffset, "background")
                local status2, mod = pcall(world.mod, matoffset, "background")
                
                if status2 and type(mod) == "string" then
                    local color = modColor(mod)
                    if color and color[4] > 0 then
                        color = {color[1] * 0.5, color[2] * 0.5, color[3] * 0.5, 255}
                        palettes = palettes..";"..compactHexString({x - 1, 0, y - 1, 1}).."="..compactHexString(color)
                        self.pcolor = _lerpColor3(self.pcolor, color, 1/32)
                        self.pcolor[4] = math.floor(255 * (x/32))
                    end
                elseif status and type(mat) == "string" then
                    local color = materialColor(mat)
                    if color and color[4] > 0 then
                        color = {color[1] * 0.5, color[2] * 0.5, color[3] * 0.5, 255}
                        palettes = palettes..";"..compactHexString({x - 1, 0, y - 1, 1}).."="..compactHexString(color)
                        self.pcolor = _lerpColor3(self.pcolor, color, 1/32)
                        self.pcolor[4] = math.floor(255 * (x/32))
                    end
                end
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