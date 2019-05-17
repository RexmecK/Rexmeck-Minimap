include "imageColor"
include "stringUtils"

local cachedMaterial = {}

function materialConfig(id)
    if not id then return {particleColor = {255,0,255,255}} end -- no id handling
    if cachedMaterial[id] then return cachedMaterial[id] end -- uses cache color so we dont have to go in configs again
    local mat = {particleColor = {255,255,255,255}}

    if id:sub(1,13) == "metamaterial:" then -- can't get metamateriall
    else
        local a = root.materialConfig(id)
        if a then
            mat = a
        end
    end

    cachedMaterial[id] = mat
    return cachedMaterial[id]
end

local cachedMaterialColor = {}

function materialColor(id)
    if cachedMaterialColor[id] then return cachedMaterialColor[id] end
    local mConfig = materialConfig(id)

    if mConfig.config and mConfig.config.color then
        cachedModColor[mod] = mConfig.config.color
    elseif mConfig.config and not mConfig.config.particleColor and mConfig.config.renderParameters and mConfig.config.renderParameters.texture then
        -- if no particle color then we're gonna use the texture trick
        local path = mConfig.config.renderParameters.texture
        if path:sub(1,1) ~= "/" then path = removeFile(mConfig.path)..path end
        mConfig.config.particleColor = getImageColor(path)
    end

    cachedMaterialColor[id] = (mConfig.config or {}).particleColor or {255,0,255,255}
    return cachedMaterialColor[id]
end

local cachedMod = {}

function modConfig(id)
    if not id then return {renderParameters = {texture = "/tiles/mods/diamond.png"}} end
    if cachedMod[id] then return cachedMod[id] end
    local mod = {config = {renderParameters = {texture = "/tiles/mods/diamond.png"}}}

    local a = root.modConfig(id)
    if a then
        mod = a
    end

    cachedMod[id] = mod
    return cachedMod[id]
end

local cachedModColor = {}

function modColor(id)
    if cachedModColor[id] then return cachedModColor[id] end
    local mConfig = modConfig(id)

    if mConfig.config and mConfig.config.color then -- if a modder decides to put his material color for the radar
        cachedModColor[id] = mConfig.config.color
    elseif mConfig.config and mConfig.config.renderParameters and mConfig.config.renderParameters.texture then -- else it will be guessed
        local path = mConfig.config.renderParameters.texture
        if path:sub(1,1) ~= "/" then path = removeFile(mConfig.path)..path end
        cachedModColor[id] = getImageColor(path)
    end
    
    cachedModColor[id] = cachedModColor[id] or {255,255,255,255}
    cachedModColor[id][4] = 255
    return cachedModColor[id]
end

local cachedLiquidConfig = {}

function liquidConfig(id)
    if not id then return {config = {color = {255,0,255,255}}} end -- no id handling
    if cachedLiquidConfig[id] then return cachedLiquidConfig[id] end -- uses cache color so we dont have to go in configs again
    local liquid = {config = {color = {255,0,255,255}}} 

    local a = root.liquidConfig(id)
    if a then
        liquid = a
    end

    cachedLiquidConfig[id] = liquid
    return cachedLiquidConfig[id]
end

local cachedLiquidColor = {}

function liquidColor(id)
    if cachedLiquidColor[id] then return cachedLiquidColor[id] end
    local mConfig = liquidConfig(id)

    if mConfig.config and mConfig.config.color then
        cachedLiquidColor[id] = mConfig.config.color
    end

    cachedLiquidColor[id] = cachedLiquidColor[id] or {255,0,255,255}
    return cachedLiquidColor[id]
end

