--updatable coroutines
uCoroutine = {}
uCoroutine.finished = false
uCoroutine._result = {}
function uCoroutine:new(func)
    local runtime = {}
    for i,v in pairs(self) do
        runtime[i] = v
    end
    runtime.coroutine = coroutine.create(
        function() 
            while true do 
                runtime._result = {func()} 
                runtime.finished = true
                coroutine.yield()
                runtime._result = {} 
                runtime.finished = false
            end 
        end
    )
    return runtime
end

function uCoroutine:result()
    return table.unpack(self._result)
end

function uCoroutine:resume()
    return coroutine.resume(self.coroutine)
end

function uCoroutine:status()
    if self.finished then return "finished" end
    return coroutine.status(self.coroutine)
end