module = {}

function module:init()
    
end

function module:callback()
    if self.func then
        self.func()
    end
end

function module:bind(func)
    self.func = func
end