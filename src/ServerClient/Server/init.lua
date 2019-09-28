
local SyncComponent = require(script.SyncComponent)

local Utilities = require(script.Parent.Utilities)
local ACCESS_TYPE = Utilities.ACCESS_TYPE

local IsType = require(script.Parent.IsType)
local IsComponentAccessType = IsType.ComponentAccessType

local root = script.Parent.Parent

local rootIsType = require(root.IsType)
local IsEntity = rootIsType.Entity

local GetOrCreateEntity = require(root.GetOrCreateEntity)


local ECSServerFramework = {}

ECSServerFramework.ACCESS_TYPE = ACCESS_TYPE

ECSServerFramework.Engine = require(script.Engine)
ECSServerFramework.EngineConfiguration = require(script.EngineConfiguration)
ECSServerFramework.SetupEngineConfiguration = require(script.SetupEngineConfiguration)
ECSServerFramework.ComponentAccessTypes = require(script.ComponentAccessTypes)


local function SetComponentAccessType(entity, componentName, componentAccessType)
    assert(IsEntity(entity), "Arg [1] is not an Entity!")
    assert(type(componentName) == "string", "Arg [2] is not a string!")
    assert(IsComponentAccessType(componentAccessType), "Arg [3] is not a ComponentAccessType!")

    local syncComponent = entity:GetComponent("SyncComponent")
    assert(syncComponent, "Arg [1] does not have a SyncComponent!")

    local componentData = syncComponent:CopyData()
    componentData.AccessData[componentName] = componentAccessType

    entity:AddComponent(
        SyncComponent:Build(componentData)
    )
end

ECSServerFramework.SetComponentAccessType = SetComponentAccessType


local function CreateSyncedEntity(entity)
    entity = GetOrCreateEntity(entity)

    entity:AddComponent(
        SyncComponent:Build()
    )

    return entity
end

ECSServerFramework.CreateSyncedEntity = CreateSyncedEntity


return ECSServerFramework