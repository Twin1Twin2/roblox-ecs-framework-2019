--- Manages a list of entities and when their components change
--

local RunService = game:GetService("RunService")


local root = script.Parent.Parent

local IsType = require(root.IsType)
local IsEntity = IsType.Entity
local IsComponentRequirement = IsType.ComponentRequirement
local IsWorld = IsType.World

local Table = require(root.Table)
local GetIndex = Table.GetIndex

local Signal = require(root.Signal)


local EntityManager = {
    ClassName = "EntityManager";
}

EntityManager.__index = EntityManager

EntityManager.IsType = IsType.EntityManager



--- Creates a new EntityManager
--
function EntityManager.new(world)
    assert(IsWorld(world), "Arg [1] is not an ECSWorld!")

    local self = setmetatable({}, EntityManager)

    self._IsEntityManager = true

    self.World = world

    self.Entities = {}  -- Dictionary<ECSEntity>

    self.OnEntityAdded = Signal.new()
    self.OnEntityRemoved = Signal.new()
    self.OnEntityComponentsAdded = Signal.new()
    self.OnEntityComponentsRemoved = Signal.new()
    self.OnEntityComponentUpdated = Signal.new()


    return self
end


function EntityManager:EntityAdded(entity)
    self.OnEntityAdded:Fire(entity)
end


function EntityManager:EntityRemoved(entity)
    self.OnEntityRemoved:Fire(entity)
end


--- Called when components are added to an Entity
-- @tparam ECSEntity entity
-- @tparam ECSComponents[] addedComponents
function EntityManager:EntityComponentsAdded(entity, addedComponents)
    if (entity._IsBeingRemoved == true) then
        return
    end

    self.OnEntityComponentsAdded:Fire(entity, addedComponents)
end


--- Called when components are removed from an Entity
-- @tparam ECSEntity entity
-- @tparam string[] removedComponents
function EntityManager:EntityComponentsRemoved(entity, removedComponents)
    if (entity._IsBeingRemoved == true) then
        return
    end

    self.OnEntityComponentsRemoved:Fire(entity, removedComponents)
end


function EntityManager:EntityComponentUpdated(entity, updatedComponentName)
    if (entity._IsBeingRemoved == true) then
        return
    end

    self.OnEntityComponentUpdated:Fire(entity, updatedComponentName)
end


--- Returns the Entity attached to the given instance
-- @tparam Instance instance
-- @treturn ECSEntity
function EntityManager:GetEntityFromInstance(instance)
    if (instance == nil) then
        return nil
    end

    assert(typeof(instance) == "Instance")

    return self.Entities[instance]
end


--- Returns the Entity that is attached to or contains the given Instance
-- @tparam Instance instance
-- @treturn ECSEntity
function EntityManager:GetEntityContainingInstance(instance)
    if (instance == nil) then
        return
    end

    assert(typeof(instance) == "Instance")

    local currentEntity = nil

    for _, entity in pairs(self.Entities) do
        if (entity:ContainsInstance(instance) == true) then
            if (currentEntity ~= nil) then
                if (currentEntity.Instance:IsAncestorOf(entity.Instance) == true) then
                    currentEntity = entity
                end
            else
                currentEntity = entity
            end
        end
    end

    return currentEntity
end


--- Waits for an Entity to be added with the following instance
-- @tparam Instance instance
-- @tparam ?number maxWaitTime
-- @treturn ECSEntity
function EntityManager:WaitForEntityWithInstance(instance, maxWaitTime)
    if (instance == nil) then
        return
    end

    assert(typeof(instance) == "Instance", "Arg [1] is not an Instance!")
    assert(maxWaitTime == nil or (type(maxWaitTime) == "number" and maxWaitTime >= 0), "Arg [2] is not a number!")

    local entity = self:GetEntityFromInstance(instance)

    if (entity ~= nil) then
        return entity
    end

    local startTime = tick()

    while (entity == nil and (maxWaitTime == nil or tick() - startTime < maxWaitTime)) do
        RunService.Heartbeat:Wait()

        entity = self:GetEntityFromInstance(instance)
    end

    return entity
end


--- Return a list of all the Entities in this manager
-- @treturn ECSEntity[]
function EntityManager:GetEntities()
    local entities = {}

    for _, entity in pairs(self.Entities) do
        table.insert(entities, entity)
    end

    return entities
end


--- Adds an Entity to this Manager
-- @tparam ECSEntity entity
function EntityManager:Add(entity)
    assert(IsEntity(entity), "Arg [1] is not an ECSEntity!")

    local entityInstance = entity.Instance

    if (typeof(entityInstance) ~= "Instance") then
        warn("Entity's Instance was removed before it was able to be added!")
        return
    end

    if (self.Entities[entityInstance] ~= nil) then  -- entity instance is already in this world (unable to overwrite)
        error("Attempted to add Entity with Instance owned by a different entity!")
    end

    entity._IsBeingRemoved = false
    entity.ComponentsAddedCallback = function(changedEntity, addedComponents)
        self:EntityComponentsAdded(changedEntity, addedComponents)
    end
    entity.ComponentsRemovedCallback = function(changedEntity, removedComponents)
        self:EntityComponentsRemoved(changedEntity, removedComponents)
    end
    entity.ComponentUpdatedCallback = function(changedEntity, componentName)
        self:EntityComponentUpdated(changedEntity, componentName)
    end

    -- add entity
    self.Entities[entityInstance] = entity
    self:EntityAdded(entity)
end


--- Removes an Entity from this manager
-- @tparam ECSEntity entity
function EntityManager:Remove(entity)
    assert(IsEntity(entity), "Arg [1] is not an ECSEntity!")

    local entityIndex = GetIndex(self.Entities, entity) -- find if entity is in this manager

    if (entityIndex == nil) then
        return
    end

    entity._IsBeingRemoved = true
    entity.ComponentsAddedCallback = function() end
    entity.ComponentsRemovedCallback = function() end

    self.Entities[entityIndex] = nil
    self:EntityRemoved(entity)
end


--- Returns all Entities that meet the given ComponentRequirement
-- @tparam ECSComponentRequirement
-- @treturn ECSEntity[]
function EntityManager:GetEntitiesMeetingRequirement(componentRequirement)
    assert(IsComponentRequirement(componentRequirement), "Arg [1] is not a ECSComponentRequirement")

    -- get list of entities
    local entitiesMet = {}

    for _, entity in pairs(self.Entities) do
        if (componentRequirement:EntityBelongs(componentRequirement) == true) then
            table.insert(entitiesMet, entity)
        end
    end

    return entitiesMet
end


return EntityManager