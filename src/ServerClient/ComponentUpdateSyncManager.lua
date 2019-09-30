--- Queues components to be updated every heartbeat (Update())
-- Used by both Server and Client

local root = script.Parent.Parent
local ComponentDescription = require(root.ECSComponentDescription)
local System = require(root.ECSSystem)


--- Holds the names of components that have been updated in this entity
--
local ComponentsUpdatedComponent = ComponentDescription.new("ComponentsUpdatedComponent")

ComponentsUpdatedComponent.Fields = {
    "ComponentsUpdated"
}

ComponentsUpdatedComponent.Defaults = {
    ComponentsUpdated = {}
}


--- Updates
local ComponentUpdateSystem = {
    ClassName = "ComponentUpdateSystem";
}

ComponentUpdateSystem.__index = ComponentUpdateSystem
setmetatable(ComponentUpdateSystem, System)


function ComponentUpdateSystem.new(syncManager)
    local self = setmetatable(System.new(), ComponentUpdateSystem)

    self.ComponentRequirement
        :All("SyncComponent")
        :All("ComponentsUpdatedComponent")

    self.SyncManager = syncManager


    return self
end


function ComponentUpdateSystem:UpdateEntity(entity)
    local componentUpdatedComponent = entity:GetComponent("ComponentsUpdatedComponent")
    local componentsUpdated = componentUpdatedComponent.ComponentsUpdated

    for componentName, hasBeenUpdated in pairs(componentsUpdated) do
        if (hasBeenUpdated == true) then
            -- fire sync manager to update
            self.SyncManager:ComponentUpdated(entity, componentName)
        end
    end

    entity:RemoveComponent("ComponentsUpdatedComponent")  -- remove from system
end


function ComponentUpdateSystem:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


--- Manages component syncing
local ComponentUpdateSyncManager = {
    ClassName = "ComponentUpdateSyncManager";
}

ComponentUpdateSyncManager.__index = ComponentUpdateSyncManager


function ComponentUpdateSyncManager.new(syncManager, world)
    local self = setmetatable({}, ComponentUpdateSyncManager)

    self.SyncManager = syncManager

    self.ComponentUpdateSystem = ComponentUpdateSystem.new(syncManager)
    world:AddSystem(self.ComponentUpdateSystem)


    return self
end


function ComponentUpdateSyncManager:EntityComponentUpdated(entity, componentName)
    if (componentName == "ComponentsUpdatedComponent") then
        return
    elseif (entity:HasComponent("SyncComponent") == false) then
        return
    end

    local componentUpdatedComponent = entity:GetComponent("ComponentsUpdatedComponent")

    if (componentUpdatedComponent == nil) then
        componentUpdatedComponent = ComponentsUpdatedComponent:Build({
            ComponentsUpdated = {
                [componentName] = true;
            }
        })
        entity:AddComponent(componentUpdatedComponent)
    else
        local componentsUpdated = componentUpdatedComponent.ComponentsUpdated
        componentsUpdated[componentName] = true
    end
end


--- Forces a component to be updated.
function ComponentUpdateSyncManager:ForceComponentUpdated(entity, componentName)
    assert(componentName ~= "ComponentsUpdatedComponent", "Arg [1] cannot be synced!")
    assert(entity:HasComponent("SyncComponent"), "Arg [1] does not have a SyncComponent!")

    -- check if component has been marked to be updated
        -- if so, unmark
    local componentUpdatedComponent = entity:GetComponent("ComponentsUpdatedComponent")
    if (componentUpdatedComponent ~= nil) then
        local componentsUpdated = componentUpdatedComponent.ComponentsUpdated
        componentsUpdated[componentName] = false
    end

    -- update component
    self.SyncManager:ComponentUpdated(entity, componentName)
end


function ComponentUpdateSyncManager:Update()
    -- sync all components
    self.ComponentUpdateSystem:DoUpdate()
end


return ComponentUpdateSyncManager