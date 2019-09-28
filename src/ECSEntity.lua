--- Entity
--

local IsType = require(script.Parent.IsType)
local IsComponent = IsType.Component
local IsComponentGroup = IsType.ComponentGroup


local ECSEntity = {
    ClassName = "ECSEntity";
}

ECSEntity.__index = ECSEntity

ECSEntity.IsType = IsType.Entity


--- Creates a new ECSEntity
-- If Instance is not given, then creates a new Model and sets as the instance
-- @tparam ?Instance instance
function ECSEntity.new(instance)
    if (instance == nil) then
        instance = Instance.new("Model")
    end

    assert(typeof(instance) == "Instance", "Entity must be attached to an Instance")

    local self = setmetatable({}, ECSEntity)

    self._IsEntity = true

    self.Instance = instance

    self.Components = {}

    self.ComponentsAddedCallback = function() end   -- set when added to an EntityManager
    self.ComponentsRemovedCallback = function() end -- set when added to an EntityManager
    self.ComponentUpdatedCallback = function() end  -- set when added to an EntityManager

    self._IsBeingRemoved = false
    self._IsBeingDestroyed = false


    return self
end


--- Deconstructor
--
function ECSEntity:Destroy()
    if (self._IsBeingDestroyed == true) then
        return
    end

    self._IsBeingDestroyed = true

    for componentName, _ in pairs(self.Components) do
        self:_RemoveComponent(componentName)
    end

    if (typeof(self.Instance) == "Instance") then
        self.Instance:Destroy()
    end

    self.Instance = nil
    self.Components = nil


    setmetatable(self, nil)
end


function ECSEntity:AddToTable(entityTable)
    -- reference counting
end


function ECSEntity:RemoveFromTable(entityTable)
    -- reference counting
end


function ECSEntity:ContainsInstance(instance)
    local selfInstance = self.Instance

    return selfInstance ~= nil and (selfInstance == instance or selfInstance:IsAncestorOf(instance))
end


function ECSEntity:CopyData()
    local data = {}

    for componentName, component in pairs(self.Components) do
        if (component ~= nil) then
            data[componentName] = component:CopyData()
        end
    end

    return data
end


--- Prints the names of the components
-- Useful for debugging
function ECSEntity:PrintComponents()
    print(self.Instance.Name)

    for componentName, _ in pairs(self.Components) do
        print("    " .. componentName)
    end
end


-- Component

function ECSEntity:HasComponent(componentName)
    if (componentName == nil) then
        return false
    end

    assert(type(componentName) == "string", "Arg [1] is not a string!")

    return self.Components[componentName] ~= nil
end


function ECSEntity:HasComponents(...)
    local components = {...}
    local hasAllComponents = true

    if (type(components[1]) == "table") then
        components = components[1]
    end

    if (#components == 0) then
        return false
    end

    for _, componentName in pairs(components) do
        if (self:HasComponent(componentName) == false) then
            hasAllComponents = false
        end
    end

    return hasAllComponents
end


function ECSEntity:GetComponent(componentName)
    assert(type(componentName) == "string", "Arg [1] must be a string!")

    return self.Components[componentName]
end


--- Returns components
-- @treturn ECSComponent
function ECSEntity:GetComponents(...)
    local components = {}

    for index, componentName in ipairs({...}) do
        assert(type(componentName) == "string", "Arg [" .. tostring(index) .. "] must be a string!")
        components[index] = self:GetComponent(componentName)
    end

    return unpack(components)
end


--- Returns components from ComponentGroup
-- @treturn ECSComponent
function ECSEntity:GetComponentsFromGroup(componentGroup)
    assert(IsComponentGroup(componentGroup), "Arg [1] is not a ComponentGroup!")

    return self:GetComponents(componentGroup:GetComponentList())
end


function ECSEntity:GetComponentList()
    local componentList = {}

    for componentName, _ in pairs(self.Components) do
        table.insert(componentList, componentName)
    end

    return componentList
end


function ECSEntity:_ComponentsAdded(componentsAdded)
    if (self._IsBeingRemoved == false and self._IsBeingDestroyed == false) then
        self.ComponentsAddedCallback(self, componentsAdded)
    end
end


function ECSEntity:_ComponentsRemoved(componentsRemoved)
    if (self._IsBeingRemoved == false and self._IsBeingDestroyed == false) then
        self.ComponentsRemovedCallback(self, componentsRemoved)
    end
end


function ECSEntity:_ComponentUpdated(componentUpdated)
    if (self._IsBeingRemoved == false and self._IsBeingDestroyed == false) then
        self.ComponentUpdatedCallback(self, componentUpdated)
    end
end


function ECSEntity:_AddComponent(component)
    local componentName = component._COMPONENT_NAME
    local overwritedComponent = self.Components[componentName] ~= nil

    if (overwritedComponent == true) then
        self:_RemoveComponent(componentName)
    end

    self.Components[componentName] = component
    component:Initialize(self)

    return overwritedComponent
end


function ECSEntity:_RemoveComponent(componentName)
    local component = self.Components[componentName]

    if (component == nil) then
        return
    end

    component:Destroy(self)
    self.Components[componentName] = nil
end


function ECSEntity:AddComponent(newComponent)
    assert(IsComponent(newComponent), "Arg [1] is not a ECSComponent!")

    local overwritedComponent = self:_AddComponent(newComponent)

    if (overwritedComponent == false) then
        self:_ComponentsAdded({newComponent._COMPONENT_NAME})
    else
        self:_ComponentUpdated(newComponent._COMPONENT_NAME)
    end
end


function ECSEntity:AddComponents(...)
    local components = {...}

    -- check if it is a table of components instead of arguments
    local firstIndex = components[1]

    if (#components == 1 and type(firstIndex) == "table" and IsComponent(firstIndex) == false) then
        components = firstIndex
    end

    if (#components == 0) then
        return
    end

    local addedComponents = {}

    for _, component in pairs(components) do
        assert(IsComponent(component))

        local overwritedComponent = self:_AddComponent(component)

        if (overwritedComponent == false) then
            table.insert(addedComponents, component._COMPONENT_NAME)
        else
            self:_ComponentUpdated(component._COMPONENT_NAME)
        end
    end

    if (#addedComponents > 0) then
        self:_ComponentsAdded(addedComponents)
    end
end


function ECSEntity:RemoveComponent(componentName)
    assert(type(componentName) == "string")

    local component = self.Components[componentName]

    if (component == nil) then
        return
    end

    self:_RemoveComponent(componentName)
    self:_ComponentsRemoved({componentName})
end


function ECSEntity:RemoveComponents(...)
    local components = {...}

    if (#components == 1 and type(components[1]) == "table") then
        components = components[1]
    end

    if (#components == 0) then
        return
    end

    local componentsRemoved = {}

    for _, componentName in pairs(components) do
        assert(type(componentName) == "string")

        local component = self.Components[componentName]

        if (component ~= nil) then
            self:_RemoveComponent(componentName)
            table.insert(componentsRemoved, componentName)
        end
    end

    if (#componentsRemoved > 0) then
        self:_ComponentsRemoved(componentsRemoved)
    end
end


-- Builders

local EntityAddComponentsBuilder = {
    ClassName = "EntityAddComponentsBuilder";
}

EntityAddComponentsBuilder.__index = EntityAddComponentsBuilder


function EntityAddComponentsBuilder.new(entity)
    local self = setmetatable({}, EntityAddComponentsBuilder)

    self.List = {}
    self.Entity = entity


    return self
end


function EntityAddComponentsBuilder:Destroy()
    self.List = nil
    self.Entity = nil

    setmetatable(self, nil)
end


function EntityAddComponentsBuilder:With(component)
    assert(IsComponent(component), "Arg [1] is not a ECSComponent")

    table.insert(self.List, component)

    return self
end


function EntityAddComponentsBuilder:Finish()
    local entity = self.Entity

    entity:AddComponents(self.List)

    self:Destroy()

    return entity
end


local EntityRemoveComponentsBuilder = {
    ClassName = "EntityRemoveComponentsBuilder";
}

EntityRemoveComponentsBuilder.__index = EntityRemoveComponentsBuilder


function EntityRemoveComponentsBuilder.new(entity)
    local self = setmetatable({}, EntityRemoveComponentsBuilder)

    self.List = {}
    self.Entity = entity


    return self
end


function EntityRemoveComponentsBuilder:Destroy()
    self.List = nil
    self.Entity = nil

    setmetatable(self, nil)
end


function EntityRemoveComponentsBuilder:With(componentName)
    assert(type(componentName) == "string", "Arg [1] is not a string!")

    table.insert(self.List, componentName)

    return self
end


function EntityRemoveComponentsBuilder:Finish()
    local entity = self.Entity

    self.Entity:RemoveComponents(self.List)

    self:Destroy()

    return entity
end


function ECSEntity:Add()
    return EntityAddComponentsBuilder.new(self)
end


function ECSEntity:Remove()
    return EntityRemoveComponentsBuilder.new(self)
end


return ECSEntity