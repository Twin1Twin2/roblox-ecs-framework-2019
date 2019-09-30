
local Utilities = require(script.Parent.Parent.Utilities)

local SYNC_EVENTS = Utilities.SYNC_EVENTS
local SYNC_EVENT_ENTITY_ADDED = SYNC_EVENTS.ENTITY_ADDED
local SYNC_EVENT_ENTITY_REMOVED = SYNC_EVENTS.ENTITY_REMOVED
local SYNC_EVENT_ENTITY_ADD_COMPONENTS = SYNC_EVENTS.ENTITY_ADD_COMPONENTS
local SYNC_EVENT_ENTITY_REMOVE_COMPONENTS = SYNC_EVENTS.ENTITY_REMOVE_COMPONENTS
local SYNC_EVENT_COMPONENT_UPDATE = SYNC_EVENTS.COMPONENT_UPDATE
local SYNC_EVENT_PLAYER_READY = SYNC_EVENTS.PLAYER_READY

local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_READ_WRITE = ACCESS_TYPE.READ_WRITE

-- local GetEntitySyncDataFromComponentList = Utilities.GetEntitySyncDataFromComponentList

local SyncComponent = require(script.Parent.SyncComponent)

local serverClientRoot = script:FindFirstAncestor("ServerClient")
local ComponentUpdateSyncManager = require(serverClientRoot.ComponentUpdateSyncManager)


local SyncManager_Client = {
    ClassName = "SyncManager_Client";
}

SyncManager_Client.__index = SyncManager_Client


function SyncManager_Client.new(world, remoteEvent, entityBuilder)
    local self = setmetatable({}, SyncManager_Client)

    self.RemoteEvent = remoteEvent
    self.EntityManager = world.EntityManager
    self.SystemManager = world.SystemManager
    self.EntityBuilder = entityBuilder

    self.ComponentUpdateSyncManager = ComponentUpdateSyncManager.new(self, world)

    self._MAX_ENTITY_WAIT_TIME = 60

    self.OnClientEventConnection = nil


    return self
end


function SyncManager_Client:Ready()
    -- connect to the client event
    if (self.OnClientEventConnection ~= nil) then
        return
    end

    self.OnClientEventConnection = self.RemoteEvent.OnClientEvent:Connect(function(eventType, data)
        warn("SyncRemoteEvent Fired! " .. tostring(eventType))
        -- use t to type check the data
        if (eventType == SYNC_EVENT_ENTITY_ADDED) then
            self:EntityAddedFromServer(data)
        elseif (eventType == SYNC_EVENT_ENTITY_REMOVED) then
            self:EntityRemovedFromServer(data)
        elseif (eventType == SYNC_EVENT_ENTITY_ADD_COMPONENTS) then
            self:EntityAddedComponentsFromServer(data)
        elseif (eventType == SYNC_EVENT_ENTITY_REMOVE_COMPONENTS) then
            self:EntityRemovedComponentsFromServer(data)
        elseif (eventType == SYNC_EVENT_COMPONENT_UPDATE) then
            self:ComponentUpdatedFromServer(data)
        else
            error("Unknown Arg [1] passed to RemoteEvent! Arg [1] = ".. tostring(eventType))
        end
    end)

    -- self.OnEntityComponentUpdatedConnection = self.EntityManager.OnEntityComponentUpdated
    --     :Connect(function(entity, componentName)
    --         if (componentName ~= "ComponentUpdatedComponent" and entity:HasComponent("SyncComponent")) then
    --             self:ComponentUpdated(entity, componentName)
    --         end
    --     end)

    self.OnEntityComponentUpdatedConnection = self.EntityManager.OnEntityComponentUpdated
        :Connect(function(entity, componentName)
            self.ComponentUpdateSyncManager:EntityComponentUpdated(entity, componentName)
        end)

    self.RemoteEvent:FireServer(SYNC_EVENT_PLAYER_READY)
end


function SyncManager_Client:Destroy()
    setmetatable(self, nil)
end


function SyncManager_Client:Update()
    self.ComponentUpdateSyncManager:Update()
end


local function CreateComponentUpdatedData(entity, componentName, componentData)
    return {
        EntityInstance = entity.Instance;
        ComponentName = componentName;
        ComponentData = componentData;
    }
end


function SyncManager_Client:ComponentUpdated(entity, componentName)
    local syncComponent = entity:GetComponent("SyncComponent")
    local accessData = syncComponent.AccessData
    local componentAccessType = accessData[componentName]

    if (componentAccessType ~= ACCESS_TYPE_READ_WRITE) then
        return
    end

    local componentData = entity:GetComponent(componentName)
        :GetSyncData()

    local componentUpdateData = CreateComponentUpdatedData(
        entity,
        componentName,
        componentData
    )

    self.RemoteEvent:FireServer(SYNC_EVENT_COMPONENT_UPDATE, componentUpdateData)
end


function SyncManager_Client:EntityAddedFromServer(data)
    -- assert(EntityAddedFromServerData(data), "")

    local entityInstance = data.EntityInstance
    local componentsData = data.ComponentsData
    local syncComponentData = componentsData["SyncComponent"]

    warn("ComponentsData:")
    for i, v in pairs(componentsData) do print(i, v) end

    local entity = self.EntityBuilder:Build(entityInstance, componentsData)

    entity:Add()
        :With(
            SyncComponent:Build(syncComponentData)
        )
        :Finish()

    self.EntityManager:Add(entity)
end


function SyncManager_Client:EntityRemovedFromServer(data)
    -- assert(EntityRemovedFromServerData(data), "")

    local entityInstance = data.EntityInstance
    local entity = self.EntityManager:GetEntityFromInstance(entityInstance)

    if (entity ~= nil) then
        self.EntityManager:Remove(entity)
    end
end


function SyncManager_Client:EntityAddedComponentsFromServer(data)
    local entityInstance = data.EntityInstance
    local componentsData = data.AddedComponentsData

    -- assume entity exists and it hasn't been added yet
    local entity = self.EntityManager:WaitForEntityWithInstance(entityInstance, self._MAX_ENTITY_WAIT_TIME)
    assert(entity)

    local components = self.EntityBuilder:CreateComponentsFromData(componentsData)

    entity:AddComponents(components)
end


function SyncManager_Client:EntityRemovedComponentsFromServer(data)
    local entityInstance = data.EntityInstance
    local componentList = data.RemovedComponents

    -- assume entity exists and it hasn't been added yet
    local entity = self.EntityManager:WaitForEntityWithInstance(entityInstance, self._MAX_ENTITY_WAIT_TIME)
    assert(entity)

    entity:RemoveComponents(componentList)
end


function SyncManager_Client:ComponentUpdatedFromServer(data)
    local entityInstance = data.EntityInstance
    local componentName = data.ComponentName
    local componentData = data.ComponentData

    local entity = self.EntityManager:WaitForEntityWithInstance(entityInstance, self._MAX_ENTITY_WAIT_TIME)
    assert(entity)

    local component

    if (componentName == "SyncComponent") then
        component = SyncComponent:Build(componentData)
    else
        component = self.EntityBuilder:BuildComponent(componentName, componentData)
    end

    entity:AddComponent(component)

    if (componentName == "SyncComponent") then  -- should this use the componentupdate callback instead?
        self.SystemManager:EntityChanged(entity)
    end
end


function SyncManager_Client:ForceSyncComponent(entity, componentName)
    self.ComponentUpdateSyncManager:ForceUpdateComponent(entity, componentName)
end


return SyncManager_Client