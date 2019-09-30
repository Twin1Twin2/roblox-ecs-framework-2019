--- Sets up a World for Roblox
--

local RunService = game:GetService("RunService")

local World = require(script.Parent.World)

local root = script.Parent.Parent.Parent
local IsType = require(root.IsType)
local IsEngineConfiguration = IsType.EngineConfiguration_Server


local ECSEngine_Server = {
    ClassName = "ECSEngine_Server";
}

ECSEngine_Server.__index = ECSEngine_Server

ECSEngine_Server.IsType = IsType.Engine_Server


function ECSEngine_Server.new(engineConfiguration)
    assert(IsEngineConfiguration(engineConfiguration) == true)

    local self = setmetatable({}, ECSEngine_Server)

    local entityBuilder = engineConfiguration.EntityBuilder

    local steppedSystemUpdaterBuilder = engineConfiguration.Stepped
    local heartbeatSystemUpdaterBuilder = engineConfiguration.Heartbeat
    local noUpdateSystemUpdaterBuilder = engineConfiguration.NoUpdate


    local world = World.new(engineConfiguration.Name, entityBuilder)

    local steppedSystems = steppedSystemUpdaterBuilder:Build(world)
    local heartbeatSystems = heartbeatSystemUpdaterBuilder:Build(world)
    local noUpdateSystems = noUpdateSystemUpdaterBuilder:Build(world)

    self.World = world

    self.SteppedSystems = steppedSystems
    self.HeartbeatSystems = heartbeatSystems
    self.NoUpdateSystems = noUpdateSystems

    self.OnSteppedConnection = RunService.Stepped:Connect(function(t, stepped)
        world.SteppedDelta = stepped

        steppedSystems:Update()
    end)

    self.OnHeartbeatConnection = RunService.Heartbeat:Connect(function(stepped)
        world.HeartbeatDelta = stepped

        heartbeatSystems:Update()

        world:Update()
    end)


    return self
end


--- Deconstructor
--
function ECSEngine_Server:Destroy()
    self.OnSteppedConnection:Disconnect()
    self.OnHeartbeatConnection:Disconnect()

    setmetatable(self, nil)
end


function ECSEngine_Server:Ready()
    self.World:Ready()
end


return ECSEngine_Server