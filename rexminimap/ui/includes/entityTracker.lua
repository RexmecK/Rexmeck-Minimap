entityTracker = {}
entityTracker.tracking = false
entityTracker.rpc = false

function entityTracker:trackUniqueId(uuid)
    self.tracking = uuid
end

function entityTracker:track(id)
    if world.entityExists(id) then
        local uuid = world.entityUniqueId(id)
        if uuid then
            self:trackUniqueId(uuid)
        end
    end
end

function entityTracker:stopTracking()
    self.tracking = false
    self.rpc = false
    self.position = false
end

function entityTracker:update(dt)
    if self.tracking then
        if not self.rpc then
            self.rpc = world.findUniqueEntity(self.tracking)
        elseif self.rpc:finished() then
            local result = self.rpc:result()
            if type(result) == "nil" then
                self:stopTracking()
            else
                self.position = result
                self.rpc = world.findUniqueEntity(self.tracking)
            end
        end
    end
end