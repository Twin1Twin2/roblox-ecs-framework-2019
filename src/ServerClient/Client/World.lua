
local root = script.Parent.Parent.Parent
local ECSWorld = require(root.ECSWorld)
local Signal = require(root.Signal)

local SyncManager = require(script.Parent.SyncManager)


local ECSWorld_Client = {
    ClassName = "ECSWorld_Client";
}

ECSWorld_Client.__index = ECSWorld_Client
setmetatable(ECSWorld_Client, ECSWorld)


function ECSWorld_Client.new(name, serverData, entityBuilder)
    assert(typeof(serverData) == "Instance", "Arg [1] is not an Instance!")

    local readyValue = serverData:WaitForChild("Ready", 60)
    assert(readyValue and readyValue:IsA("BoolValue"), "Unable to find Ready object!")

    while (readyValue.Value == false) do
        wait(0.25)
    end


    local self = setmetatable(ECSWorld.new(name), ECSWorld_Client)

    local syncRemoteEvent = serverData:FindFirstChild("SyncRemoteEvent")

    self.EntityBuilder = entityBuilder
    self.SyncManager = SyncManager.new(self, syncRemoteEvent, entityBuilder)

    self.RenderSteppedDelta = 0
    self.SteppedDelta = 0
    self.HeartbeatDelta = 0

    self.OnReady = Signal.new()


    return self
end


function ECSWorld_Client:Ready()
    self.SyncManager:Ready()
end


return ECSWorld_Client