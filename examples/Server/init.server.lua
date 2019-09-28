--- Initializes Server-Side code.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage.ECSFramework)

local Entity = ECSFramework.Entity

local ECSServerFramework = ECSFramework.Server
local Engine_Server = ECSServerFramework.Engine
local EngineConfiguration_Server = ECSServerFramework.EngineConfiguration
local CreateSyncedEntity = ECSServerFramework.CreateSyncedEntity
local ACCESS_TYPE = ECSServerFramework.ACCESS_TYPE
local SetComponentAccessType = ECSServerFramework.SetComponentAccessType
local ComponentAccessTypes = ECSServerFramework.ComponentAccessTypes
local ComponentAccessType = ComponentAccessTypes.ComponentAccessType
local OwnerAccess = ComponentAccessTypes.OwnerAccess

local serverResources = script
local serverComponents = serverResources.Components
local serverSystems = serverResources.Systems

local resources = ReplicatedStorage:FindFirstChild("ECSExampleResources")
local components = resources.Components
local systems = resources.Systems


-- Setup Components and Systems

local HumanoidComponent = require(components.HumanoidComponent)
local OwnedInputComponent = require(components.OwnedInputComponent)
local TestAccessComponent = require(components.TestAccessComponent)

local engineConfiguration = EngineConfiguration_Server.new("ECSExampleEngine")

ECSServerFramework.SetupEngineConfiguration(engineConfiguration)

engineConfiguration.EntityBuilder
    :RegisterComponent(HumanoidComponent)
    :RegisterComponent(OwnedInputComponent)
    :RegisterComponent(TestAccessComponent)

engineConfiguration.NoUpdate
    :With(require(serverSystems.RandomWalkSpeedSystem).new())
    :With(require(serverSystems.TestAccessSystem).new())


-- Setup Engine

local engine = Engine_Server.new(engineConfiguration)

local world = engine.World
local serverData = world.ServerData

-- SetupStartScene(world)

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- magic wait always works :thumbsup:
        local humanoid = character:WaitForChild("Humanoid")

        local playerEntity = CreateSyncedEntity(character)
            :Add()
                :With(
                    HumanoidComponent:Build({
                        Humanoid = humanoid;
                    })
                )
                :With(
                    OwnedInputComponent:Build()
                )
                :With(
                    TestAccessComponent:Build()
                )
                :Finish()

        -- set owner as player
        local ownerAccessType = OwnerAccess.new(player, ACCESS_TYPE.READ_WRITE, ACCESS_TYPE.READ_ONLY)
        SetComponentAccessType(playerEntity, OwnedInputComponent.Name, ownerAccessType)
        SetComponentAccessType(playerEntity, HumanoidComponent.Name, ComponentAccessType.new(ACCESS_TYPE.READ_ONLY))
        SetComponentAccessType(playerEntity, TestAccessComponent.Name, ComponentAccessType.new(ACCESS_TYPE.READ_ONLY))

        world:AddEntity(playerEntity)
	end)
end)

-- Server Ready
serverData.Name = "ECSExampleEngine"
serverData.Parent = ReplicatedStorage

engine:Ready()


print("ServerMain Loaded")