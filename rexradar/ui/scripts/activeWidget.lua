function loadModule(path)
    if type(_loadedModules) ~= "table" then _loadedModules = {} end
    if type(_loadedModules[path]) ~= "nil" then return _loadedModules[path] end
    local oldmodule = module
    module = nil
    require(path)
    _loadedModules[path] = module or false
    if type(oldmodule) ~= "nil" then
        module = oldmodule
    else
        module = nil
    end
    return loadModule(path)
end

-- that is without module check
function include(name)
    require(LOCALPATH.."includes/"..name..".lua")
end

window = {}
activeWidget = {}
activeWidget.guiConfig = {}

function activeWidget:init()
    self.guiConfig = config.getParameter("gui", {})
    for name, config in pairs(self.guiConfig) do
        window[name] = config
        window[name].widgetName = name
        if config.type == "canvas" then
            window[name].canvas = widget.bindCanvas(name)
        end
        if config.script then
            local mod = loadModule(config.script)
            if type(mod) == "table" then
                for key, property in pairs(mod) do
                    window[name][key] = property
                end
            end
        end
    end

    for name, instance in pairs(window) do
        if type(instance.init) == "function" then
            window[name]:init()
        end
    end
end

function activeWidget:update(dt)
    for name, instance in pairs(window) do
        if type(instance.update) == "function" then
            window[name]:update(dt)
        end
    end
end

function activeWidget:uninit()
    for name, instance in pairs(window) do
        if type(instance.uninit) == "function" then
            window[name]:uninit()
        end
    end
end

function activeWidget:getWidgetFocus()
    for i,v in pairs(self.guiConfig) do
        if widget.hasFocus(i) then
            return i
        end
    end
end


function activeWidget:inCanvas(rect, point)
    return (rect[3] - rect[1]) > point[1] and (rect[4] - rect[2]) > point[2] and (point[1] > 0) and (point[2] > 0)
end

--callbacks

function activeWidget:enterKey(widget)
    if type(window[widget]) == "table" and type(window[widget].enterKey) == "function" then
        window[widget]:enterKey()
    end
end

function activeWidget:escapeKey(widget)
    if type(window[widget]) == "table" and type(window[widget].escapeKey) == "function" then
        window[widget]:escapeKey()
    end
end

function activeWidget:callback(widget)
    if type(window[widget]) == "table" and type(window[widget].callback) == "function" then
        window[widget]:callback()
    end
end

function activeWidget:handleMouse(position, button, isButtonDown)
    local focused = self:getWidgetFocus()
    if focused and type(window[focused]) == "table" and window[focused].rect then
        local inCanvas = self:inCanvas(window[focused].rect, position)
        if type(window[focused].handleMouse) == "function" and inCanvas then
            window[focused]:handleMouse(position, button, isButtonDown)
        elseif not inCanvas then
            widget.blur(focused)
        end
    end
end

function activeWidget:handleKeyboard(key, isButtonDown)
    local focused = self:getWidgetFocus()
    if focused and type(window[focused]) == "table" and type(window[focused].handleKeyboard) == "function" then
        window[focused]:handleKeyboard(key, isButtonDown)
    end
end