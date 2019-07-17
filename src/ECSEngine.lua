--- Sets up a World for Roblox
--

local RunService = game:GetService("RunService")

local World = require(script.Parent.ECSWorld)

local IsType = require(script.Parent.IsType)
local IsEngineConfiguration = IsType.EngineConfiguration


local ECSEngine = {
    ClassName = "ECSEngine";
}

ECSEngine.__index = ECSEngine

ECSEngine.IsType = IsType.Engine


function ECSEngine.new(engineConfiguration)
    assert(IsEngineConfiguration(engineConfiguration) == true)

    local self = setmetatable({}, ECSEngine)

    local entityBuilder = engineConfiguration.EntityBuilder

    local renderSteppedSystemUpdaterBuilder = engineConfiguration.RenderStepped
    local steppedSystemUpdaterBuilder = engineConfiguration.Stepped
    local heartbeatSystemUpdaterBuilder = engineConfiguration.Heartbeat
    local noUpdateSystemUpdaterBuilder = engineConfiguration.NoUpdate


    local world = World.new()

    local renderSteppedSystems = renderSteppedSystemUpdaterBuilder:Build(world)
    local steppedSystems = steppedSystemUpdaterBuilder:Build(world)
    local heartbeatSystems = heartbeatSystemUpdaterBuilder:Build(world)
    local noUpdateSystems = noUpdateSystemUpdaterBuilder:Build(world)

    self.World = world

    self.EntityBuilder = entityBuilder
    self.World.EntityBuilder = entityBuilder

    -- set stepped values
    self.World.RenderSteppedDelta = 0
    self.World.SteppedDelta = 0
    self.World.HearbeatDelta = 0

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
    end)


    return self
end


--- Deconstructor
--
function ECSEngine:Destroy()

    setmetatable(self, nil)
end


return ECSEngine