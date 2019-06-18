LOCALPATH = "/"
screenPosition = {0,0}

function lp(path)
    if path:sub(1,1) == "/" then
        return path
    end
    return LOCALPATH..path
end

function init()
    LOCALPATH = config.getParameter("localDir", "/")
    MAINSCRIPTPATH = config.getParameter("mainScript")
    require(lp("scripts/activeWidget.lua"))
    activeWidget:init()
    if MAINSCRIPTPATH then
        require(lp(MAINSCRIPTPATH))
        if main and main.init then
            main:init()
        end
    end
end

function update(dt)
    activeWidget:update(dt)
    if main and main.update then
        main:update(dt)
    end
end

function createTooltip(a)
    screenPosition = a
end

function uninit()
    activeWidget:uninit()
    if main and main.uninit then
        main:uninit()
    end
end

function enterKey(widget)
    activeWidget:enterKey(widget)
end

function escapeKey(widget)
    activeWidget:escapeKey(widget)
end

function callback(widget)
    activeWidget:callback(widget)
end

function handleMouse(position, button, isButtonDown)
    activeWidget:handleMouse(position, button, isButtonDown)
end

function handleKeyboard(key, isKeyDown)
    activeWidget:handleKeyboard(key, isKeyDown)
end
