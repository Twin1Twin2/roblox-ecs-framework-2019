--- Initializes Client-Side code.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage.ECSFramework)
local ECSClientFramework = ECSFramework.Client
local Engine_Client = ECSClientFramework.Engine
local EngineConfiguration_Client = ECSClientFramework.EngineConfiguration

local clientResources = script
local clientComponents = clientResources.Components
local clientSystems = clientResources.Systems

local resources = ReplicatedStorage:FindFirstChild("ECSExampleResources")
local components = resources.Components
local systems = resources.Systems


local serverData = ReplicatedStorage:WaitForChild("ECSExampleEngine")


-- Setup Components and Systems

local engineConfiguration = EngineConfiguration_Client.new()

ECSClientFramework.SetupEngineConfiguration(engineConfiguration)

engineConfiguration.EntityBuilder
    :RegisterComponent(require(components.HumanoidComponent))
    :RegisterComponent(require(components.OwnedInputComponent))
    :RegisterComponent(require(components.OwnerComponent))
    :RegisterComponent(require(components.TestAccessComponent))


engineConfiguration.NoUpdate
    :With(require(clientSystems.TestAccessDisplaySystem).new())

engineConfiguration.Heartbeat
    :With(require(clientSystems.OwnedInputUpdateSystem).new())
    :With(require(clientSystems.OwnedInputDisplaySystem).new())


-- Setup Engine

local engine = Engine_Client.new(engineConfiguration, serverData)
-- local world = engine.World

-- SetupStartScene(world)


engine:Ready()

print("ClientMain Loaded")