--- Syncs component data to and from clients
--

local Players = game:GetService("Players")

local ECSSystem = require(script:FindFirstAncestor("ServerClient").Parent.ECSSystem)

local Utilities = require(script.Parent.Parent.Utilities)

local SYNC_EVENTS = Utilities.SYNC_EVENTS
local SYNC_EVENT_ENTITY_ADDED = SYNC_EVENTS.ENTITY_ADDED
local SYNC_EVENT_ENTITY_REMOVED = SYNC_EVENTS.ENTITY_REMOVED
local SYNC_EVENT_ENTITY_ADD_COMPONENTS = SYNC_EVENTS.ENTITY_ADD_COMPONENTS
local SYNC_EVENT_ENTITY_REMOVE_COMPONENTS = SYNC_EVENTS.ENTITY_REMOVE_COMPONENTS
local SYNC_EVENT_COMPONENT_UPDATE = SYNC_EVENTS.COMPONENT_UPDATE
local SYNC_EVENT_PLAYER_READY = SYNC_EVENTS.PLAYER_READY

local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_NONE = ACCESS_TYPE.NONE
local ACCESS_TYPE_READ_WRITE = ACCESS_TYPE.READ_WRITE
local ACCESS_TYPE_READ_ONLY = ACCESS_TYPE.READ_ONLY

local IsPlayer = Utilities.IsPlayer
local IsReadAccessType = Utilities.IsReadAccessType

local serverClientRoot = script:FindFirstAncestor("ServerClient")
local ComponentUpdateSyncManager = require(serverClientRoot.ComponentUpdateSyncManager)

local root = serverClientRoot.Parent
-- local Table = require(root.Table)
-- local TableCopy = Table.Copy
local Signal = require(root.Signal)


local SyncComponentSystem = {
    ClassName = "SyncComponentSystem";
}

SyncComponentSystem.__index = SyncComponentSystem
setmetatable(SyncComponentSystem, ECSSystem)


function SyncComponentSystem.new()
    local self = setmetatable(ECSSystem.new(), SyncComponentSystem)

    self.ComponentRequirement
        :All("SyncComponent")


    return self
end


local SyncManager_Server = {
    ClassName = "SyncManager_Server";
}

SyncManager_Server.__index = SyncManager_Server


function SyncManager_Server.new(world, serverData, entityBuilder)
    local self = setmetatable({}, SyncManager_Server)

    local remoteEvent = Instance.new("RemoteEvent", serverData)
        remoteEvent.Name = "SyncRemoteEvent"

    local entityManager = world.EntityManager

    self.RemoteEvent = remoteEvent
    self.EntityManager = entityManager
    self.EntityBuilder = entityBuilder

    self.SyncComponentSystem = SyncComponentSystem.new()
    world:AddSystem(self.SyncComponentSystem)

    self.ComponentUpdateSyncManager = ComponentUpdateSyncManager.new(self, world)

    self.PlayersReady = {}
    self.RegisteredComponents = {}

    self.OnPlayerReady = Signal.new()
    self.OnPlayerUnready = Signal.new()


    self.OnServerEventConnection = remoteEvent.OnServerEvent:Connect(function(player, eventType, data)
        if (eventType == SYNC_EVENT_PLAYER_READY) then
            self:PlayerAdded(player)
        elseif (eventType == SYNC_EVENT_COMPONENT_UPDATE) then
            self:ComponentUpdatedFromClient(player, data)
        end
    end)


    self.OnEntityAddedConnection = self.SyncComponentSystem.EntityTable.OnInserted:Connect(function(entity)
        self:EntityAdded(entity)
    end)

    self.OnEntityRemovedConnection = self.SyncComponentSystem.EntityTable.OnRemoved:Connect(function(entity)
        self:EntityRemoved(entity)
    end)

    self.OnEntityComponentsAddedConnection = entityManager.OnEntityComponentsAdded
        :Connect(function(entity, addedComponents)
            if (entity:HasComponent("SyncComponent") == true) then
                self:EntityComponentsAdded(entity, addedComponents)
            end
        end)

    self.OnEntityComponentsRemovedConnection = entityManager.OnEntityComponentsRemoved
        :Connect(function(entity, removedComponents)
            if (entity:HasComponent("SyncComponent") == true) then
                self:EntityComponentsRemoved(entity, removedComponents)
            end
        end)

    self.OnEntityComponentUpdatedConnection = entityManager.OnEntityComponentUpdated
        :Connect(function(entity, componentName)
            if (componentName == "SyncComponent") then
                self:EntitySyncComponentChanged(entity)
            else
                self.ComponentUpdateSyncManager:EntityComponentUpdated(entity, componentName)
            end
        end)


    return self
end


function SyncManager_Server:Destroy()
    setmetatable(self, nil)
end


function SyncManager_Server:Update()
    self.ComponentUpdateSyncManager:Update()
end


function SyncManager_Server:FireClient(player, eventType, data)
    self.RemoteEvent:FireClient(player, eventType, data)
end


function SyncManager_Server:FireClients(player, eventType, data)
    if (IsPlayer(player) == true) then
        self:FireClient(player, eventType, data)
    elseif (type(player) == "table") then
        for _, playerClass in pairs(player) do
            assert(IsPlayer(playerClass))
            self:FireClient(playerClass, eventType, data)
        end
    else
        error("Players not given")
    end
end


--- Gets the AccessData for the player used in it's SyncComponent.
-- @tparam AccessData accessData
-- @tparam Player player
local function GetClientAccessData(accessData, player)
    local playerAccessData = {}

    for componentName, componentAccessType in pairs(accessData) do
        playerAccessData[componentName] = componentAccessType:GetForPlayer(player)
    end

    return playerAccessData
end


local function GetSyncedComponentsDataForPlayer(entity, player, accessData)
    local componentsSyncData = {}

    for componentName, componentAccessData in pairs(accessData) do
        if (IsReadAccessType(componentAccessData:GetForPlayer(player))) then
            componentsSyncData[componentName] = entity:GetComponent(componentName)
                :GetSyncData()
        end
    end

    componentsSyncData["SyncComponent"] = {
        AccessData = GetClientAccessData(accessData, player)
    }

    return componentsSyncData
end


local function GetSyncedComponentsDataForPlayerFromList(entity, player, accessData, componentsList)
    local componentsSyncData = {}
    local isEmpty = true

    for _, componentName in pairs(componentsList) do
        if (componentName == "SyncComponent") then
            componentsSyncData["SyncComponent"] = {
                AccessData = GetClientAccessData(accessData, player)
            }
            isEmpty = false
        elseif (componentName ~= "ComponentsUpdatedComponent") then
            local componentAccessData = accessData[componentName]

            if (IsReadAccessType(componentAccessData:GetForPlayer(player))) then
                componentsSyncData[componentName] = entity:GetComponent(componentName)
                    :GetSyncData()
                isEmpty = false
            end
        end
    end

    return componentsSyncData, isEmpty
end


local function CreateEntityAddedDataForPlayer(entity, player, accessData)
    local componentsData, _ = GetSyncedComponentsDataForPlayer(entity, player, accessData)
    return {
        EntityInstance = entity.Instance;
        ComponentsData = componentsData;
    }
end


function SyncManager_Server:FireEntityAdded(players, entityAddedData)
    self:FireClients(players, SYNC_EVENT_ENTITY_ADDED, entityAddedData)
end


function SyncManager_Server:EntityAdded(entity)
    local syncComponent = entity:GetComponent("SyncComponent")
    local accessData = syncComponent.AccessData
    syncComponent.PreviousAccessData = accessData

    for _, player in pairs(Players:GetPlayers()) do
        local entityAddedData = CreateEntityAddedDataForPlayer(
            entity,
            player,
            accessData
        )

        self:FireEntityAdded(player, entityAddedData)
    end
end


local function CreateEntityRemovedData(entity)
    return {
        EntityInstance = entity.Instance;
    }
end


function SyncManager_Server:FireEntityRemoved(players, entityRemovedData)
    self:FireClients(players, SYNC_EVENT_ENTITY_REMOVED, entityRemovedData)
end


function SyncManager_Server:EntityRemoved(entity)
    local entityRemovedData = CreateEntityRemovedData(entity)

    self:FireEntityRemoved(Players:GetPlayers(), entityRemovedData)
end


local function CreateEntityComponentsAddedDataForPlayer(entity, accessData, componentsAdded, player)
    local addedComponentsData, isEmpty
        = GetSyncedComponentsDataForPlayerFromList(entity, player, accessData, componentsAdded)

    return {
        EntityInstance = entity.Instance;
        AddedComponentsData = addedComponentsData;
    }, isEmpty
end


local function FilterComponentsUpdateComponentFromComponentList(componentList)
    local newComponentList = {}
    local isEmpty = true

    for _, componentName in pairs(componentList) do
        if (componentName ~= "ComponentsUpdatedComponent") then
            table.insert(newComponentList, componentName)
            isEmpty = false
        end
    end

    return newComponentList, isEmpty
end


function SyncManager_Server:FireEntityComponentsAdded(player, entityAddedData)
    self:FireClients(player, SYNC_EVENT_ENTITY_ADD_COMPONENTS, entityAddedData)
end


function SyncManager_Server:EntityComponentsAdded(entity, componentsAdded)
    local newComponentsAdded, isEmpty = FilterComponentsUpdateComponentFromComponentList(componentsAdded)
    if (isEmpty == true) then
        return
    end

    local syncComponent = entity:GetComponent("SyncComponent")
    local accessData = syncComponent.AccessData

    for _, player in pairs(Players:GetPlayers()) do
        local componentsAddedData, isPlayerComponentsAddedEmpty = CreateEntityComponentsAddedDataForPlayer(
            entity,
            accessData,
            newComponentsAdded,
            player
        )

        if (isPlayerComponentsAddedEmpty == false) then
            self:FireEntityComponentsAdded(player, componentsAddedData)
        end
    end
end


local function CreateEntityComponentsRemovedData(entity, componentsRemoved, player)
    return {
        EntityInstance = entity.Instance;
        RemovedComponents = componentsRemoved;  -- just pass them all and assume
    }
end


function SyncManager_Server:FireEntityComponentsRemoved(players, entityAddedData)
    self:FireClients(players, SYNC_EVENT_ENTITY_REMOVE_COMPONENTS, entityAddedData)
end


function SyncManager_Server:EntityComponentsRemoved(entity, removedComponents)
    local newRemovedComponents, isEmpty = FilterComponentsUpdateComponentFromComponentList(removedComponents)
    if (isEmpty == true) then
        return
    end

    local componentsRemovedData = CreateEntityComponentsRemovedData(entity, newRemovedComponents)

    self:FireEntityComponentsRemoved(Players:GetPlayers(), componentsRemovedData)
end


local function CreateComponentUpdatedData(entity, componentName, componentData)
    return {
        EntityInstance = entity.Instance;
        ComponentName = componentName;
        ComponentData = componentData;
    }
end


function SyncManager_Server:FireComponentUpdated(players, componentUpdateData)
    self:FireClients(players, SYNC_EVENT_COMPONENT_UPDATE, componentUpdateData)
end


function SyncManager_Server:SyncAccessDataForPlayer(entity, accessData, player)
    local playerAccessData = GetClientAccessData(accessData, player)
    local syncComponentData = {
        AccessData = playerAccessData;
    }

    -- send a component update with data
    local componentUpdateData = CreateComponentUpdatedData(
        entity,
        "SyncComponent",
        syncComponentData
    )

    self:FireComponentUpdated(player, componentUpdateData)
end


function SyncManager_Server:EntitySyncComponentChanged(entity)
    -- assume it has been synced b/c it has a sync component
    local syncComponent = entity:GetComponent("SyncComponent")
    local accessData = syncComponent.AccessData
    local previousAccessData = syncComponent.PreviousAccessData

    -- sync access data
    for _, player in pairs(Players:GetPlayers()) do
        self:SyncAccessDataForPlayer(entity, accessData, player)
    end

    -- check changes between access data per player
    for _, player in pairs(Players:GetPlayers()) do
        local playerAccessData = GetClientAccessData(accessData, player)
        local playerPreviousAccessData = GetClientAccessData(previousAccessData, player)

        local addedComponents = {}
        local removedComponents = {}

        for componentName, currentComponentAccessType in pairs(playerAccessData) do
            local previousComponentAccessType = playerPreviousAccessData[componentName]

            if (IsReadAccessType(previousComponentAccessType) == false
                and IsReadAccessType(currentComponentAccessType) == true) then
                table.insert(addedComponents, componentName)
            end
        end

        for componentName, previousComponentAccessType in pairs(playerPreviousAccessData) do
            local currentComponentAccessType = playerAccessData[componentName]

            if (IsReadAccessType(currentComponentAccessType) == false
                and IsReadAccessType(previousComponentAccessType) == true) then
                table.insert(removedComponents, componentName)
            end
        end

        if (#addedComponents > 0) then
            -- fire player components added
            local componentsAddedData = CreateEntityComponentsAddedDataForPlayer(
                entity,
                accessData,
                addedComponents,
                player
            )

            self:FireEntityComponentsAdded(player, componentsAddedData)
        end

        if (#removedComponents > 0) then
            -- fire player components removed
            local componentsRemovedData = CreateEntityComponentsRemovedData(entity, removedComponents)

            self:FireEntityComponentsRemoved(player, componentsRemovedData)
        end
    end

    -- probably will memory leak
    --      need to figure out destroying for this

    -- buggy
    -- for _, componentAccessType in pairs(previousAccessData) do
    --     componentAccessType:Destroy()
    -- end

    syncComponent.PreviousAccessData = accessData
end


local function GetPlayersWithReadOnlyAccessToComponent(componentAccessType)
    local players = {}

    for _, player in pairs(Players:GetPlayers()) do
        if (componentAccessType:GetForPlayer(player) == ACCESS_TYPE_READ_ONLY) then
            table.insert(players, player)
        end
    end

    return players
end


function SyncManager_Server:ComponentUpdated(entity, componentName)
    local syncComponent = entity:GetComponent("SyncComponent")
    local accessData = syncComponent.AccessData
    local componentAccessType = accessData[componentName]
    local players = GetPlayersWithReadOnlyAccessToComponent(componentAccessType, componentName)

    local componentData = entity:GetComponent(componentName)
        :GetSyncData()

    if (#players == 0) then
        return
    end

    local componentUpdateData = CreateComponentUpdatedData(
        entity,
        componentName,
        componentData
    )

    self:FireComponentUpdated(players, componentUpdateData)
end


local function GetPlayerAccessDataForComponent(player, accessData, componentName)
    local componentAccessType = accessData[componentName]

    if (componentAccessType == nil) then
        return ACCESS_TYPE_NONE
    end

    local accessType = componentAccessType:GetForPlayer(player)

    return accessType or 0
end


function SyncManager_Server:PlayerAdded(player)
    -- sync a snapshot of the server
    local entities = self.SyncComponentSystem.EntityTable:GetCopy()

    for _, entity in pairs(entities) do
        local entityAddedData = CreateEntityAddedDataForPlayer(
            entity,
            player
        )

        self:FireEntityAdded(player, entityAddedData)
    end

    self.OnPlayerReady:Fire()
end


local function DoesPlayerHaveWriteAccess(player, accessData, componentName)
    local accessType = GetPlayerAccessDataForComponent(player, accessData, componentName)

    return accessType == ACCESS_TYPE_READ_WRITE
end


function SyncManager_Server:ComponentUpdatedFromClient(player, data)
    -- validate data with t

    local entityInstance = data.EntityInstance
    local componentName = data.ComponentName
    local componentData = data.ComponentData

    local entity = self.EntityManager:GetEntityFromInstance(entityInstance)
    assert(entity)

    local syncComponent = entity:GetComponent("SyncComponent")

    assert(syncComponent, "Player tried to update an entity without a sync component!")

    local accessData = syncComponent.AccessData

    -- check if client has write access to this component
    assert(DoesPlayerHaveWriteAccess(player, accessData, componentName),
        "Player " .. player.Name .. " tried to update component "
        .. componentName .. " but does not have write access!")
    warn("Player " .. player.Name .. " - Component " .. componentName .. " Updated!")
    -- resets the component updated value
    local component = self.EntityBuilder:BuildComponent(componentName, componentData)

    entity:AddComponent(component)
end


function SyncManager_Server:ForceSyncComponent(entity, componentName)
    self.ComponentUpdateSyncManager:ForceUpdateComponent(entity, componentName)
end


return SyncManager_Server