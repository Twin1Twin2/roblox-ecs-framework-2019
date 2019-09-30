--- Sets up a World for Roblox
--

local RunService = game:GetService("RunService")

local World = require(script.Parent.World)

local root = script.Parent.Parent.Parent
local IsType = require(root.IsType)
local IsEngineConfiguration = IsType.EngineConfiguration_Client


local ECSEngine_Client = {
    ClassName = "ECSEngine_Client";
}

ECSEngine_Client.__index = ECSEngine_Client

ECSEngine_Client.IsType = IsType.Engine_Client


function ECSEngine_Client.new(engineConfiguration, serverData)
    assert(IsEngineConfiguration(engineConfiguration) == true)

    local self = setmetatable({}, ECSEngine_Client)

    local entityBuilder = engineConfiguration.EntityBuilder

    local renderSteppedSystemUpdaterBuilder = engineConfiguration.RenderStepped
    local steppedSystemUpdaterBuilder = engineConfiguration.Stepped
    local heartbeatSystemUpdaterBuilder = engineConfiguration.Heartbeat
    local noUpdateSystemUpdaterBuilder = engineConfiguration.NoUpdate


    local world = World.new(engineConfiguration.Name, serverData, entityBuilder)

    local renderSteppedSystems = renderSteppedSystemUpdaterBuilder:Build(world)
    local steppedSystems = steppedSystemUpdaterBuilder:Build(world)
    local heartbeatSystems = heartbeatSystemUpdaterBuilder:Build(world)
    local noUpdateSystems = noUpdateSystemUpdaterBuilder:Build(world)


    self.World = world

    self.RenderSteppedSystems = renderSteppedSystems
    self.SteppedSystems = steppedSystems
    self.HeartbeatSystems = heartbeatSystems
    self.NoUpdateSystems = noUpdateSystems

    self.OnRenderSteppedConnection = RunService.RenderStepped:Connect(function(stepped)
        world.RenderSteppedDelta = stepped

        renderSteppedSystems:Update()
    end)

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
function ECSEngine_Client:Destroy()
    self.OnRenderSteppedConnection:Disconnect()
    self.OnSteppedConnection:Disconnect()
    self.OnHeartbeatConnection:Disconnect()

    setmetatable(self, nil)
end


function ECSEngine_Client:Ready()
    self.World:Ready()
end


return ECSEngine_Client