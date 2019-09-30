
local root = script.Parent.Parent.Parent
local ECSWorld = require(root.ECSWorld)

local SyncManager = require(script.Parent.SyncManager)


local ECSWorld_Server = {
    ClassName = "ECSWorld_Server";
}

ECSWorld_Server.__index = ECSWorld_Server
setmetatable(ECSWorld_Server, ECSWorld)


function ECSWorld_Server.new(name, entityBuilder)
    local self = setmetatable(ECSWorld.new(name), ECSWorld_Server)

    local serverData = Instance.new("Folder")

    local readyValue = Instance.new("BoolValue", serverData)
        readyValue.Name = "Ready"
        readyValue.Value = false

    self.ServerData = serverData
    self.ReadyValue = readyValue

    self.EntityBuilder = entityBuilder
    self.SyncManager = SyncManager.new(self, serverData, entityBuilder)

    self.SteppedDelta = 0
    self.HeartbeatDelta = 0


    return self
end


function ECSWorld_Server:Update()
    self.SyncManager:Update()
end


function ECSWorld_Server:Ready()
    if (self.ReadyValue.Value == true) then
        return
    end

    self.ReadyValue.Value = true
end


return ECSWorld_Server