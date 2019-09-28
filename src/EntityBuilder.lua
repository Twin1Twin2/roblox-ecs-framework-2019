--- Converts data in an Instance into an ECSEntity
-- Components defined in the Instance data must be registed in this object

local Entity = require(script.Parent.ECSEntity)

local IsType = require(script.Parent.IsType)
local IsComponentDescription = IsType.ComponentDescription
local IsComponentGroup = IsType.ComponentGroup

local Table = require(script.Parent.Table)
local TableMerge = Table.Merge


local COMPONENTS_INSTANCE_DATA_NAME = "COMPONENTS"
local COMPONENTS_MODULE_DATA_NAME = "COMPONENT_DATA"
local COMPONENT_GROUPS_INSTANCE_DATA_NAME = "COMPONENT_GROUPS"

local EntityBuilder = {
    ClassName = "EntityBuilder";
}

EntityBuilder.__index = EntityBuilder

EntityBuilder.IsType = IsType.EntityBuilder


--- Creates a new EntityBuilder
-- @treturn EntityBuilder
function EntityBuilder.new()
    local self = setmetatable({}, EntityBuilder)

    self._IsEntityBuilder = true

    self.RegisteredComponents = {}
    self.RegisteredComponentGroups = {}


    return self
end


-- Registering

function EntityBuilder:GetComponentDescription(componentName)
    assert(type(componentName) == "string")

    return self.RegisteredComponents[componentName]
end


--- Registers a ComponentDescription
-- @tparam ECSComponentDescription componentDesc
function EntityBuilder:RegisterComponent(componentDesc)
    assert(IsComponentDescription(componentDesc), "Arg [1] is not a ECSComponentDescription!")

    local componentName = componentDesc.Name

    self.RegisteredComponents[componentName] = componentDesc

    return self
end


function EntityBuilder:GetComponentGroup(componentGroupName)
    assert(type(componentGroupName) == "string")

    return self.RegisteredComponentGroups[componentGroupName]
end


--- Registers a ComponentDescription
-- @tparam ECSComponentGroup componentGroup
function EntityBuilder:RegisterComponentGroup(componentGroup)
    assert(IsComponentGroup(componentGroup), "Arg [1] is not a ECSComponentGroup")

    local componentGroupName = componentGroup.Name

    self.RegisteredComponentGroups[componentGroupName] = componentGroup

    return self
end


-- Entity Building

local function GetDataFromInstance(instance)
    local data = instance

    if (data:IsA("ValueBase") == true) then
        data = instance.Value
    end

    return data
end


local function GetDataForComponentFieldFromInstance(instance)
    local data = instance

    -- Configuration == this is an array
    if (data:IsA("Configuration") == true) then
        local a = {}

        for _, child in pairs(data:GetChildren()) do
            local index = tonumber(child.Name)

            if (index ~= nil) then
                local d = GetDataFromInstance(child)
                a[index] = d
            end
        end

        data = a
    elseif (data:IsA("ValueBase") == true) then
        data = instance.Value
    end

    return data
end


---
function EntityBuilder:GetComponentDataFromInstance(instanceData)
    local componentData = {}
    local componentGroupData = {}

    local componentsInstanceData = instanceData:FindFirstChild(COMPONENTS_INSTANCE_DATA_NAME)
    local componentsModuleData = instanceData:FindFirstChild(COMPONENTS_MODULE_DATA_NAME)
    local componentGroupsInstanceData = instanceData:FindFirstChild(COMPONENT_GROUPS_INSTANCE_DATA_NAME)

    if (componentsModuleData ~= nil) then
        local moduleData = require(componentsModuleData)
        assert(type(moduleData) == "table", "Module did not return a table!")

        -- sanitize/check data? nah

        -- component group data?

        componentData = moduleData
    end

    if (componentsInstanceData ~= nil) then
        for _, componentInstanceData in pairs(componentsInstanceData:GetChildren()) do
            local componentName = componentInstanceData.Name
            local data = {}

            for _, valueInstance in pairs(componentInstanceData:GetChildren()) do
                local valueName = valueInstance.Name
                data[valueName] = GetDataForComponentFieldFromInstance(valueInstance)
            end

            componentData[componentName] = data
        end
    end

    if (componentGroupsInstanceData ~= nil) then
        for _, componentGroupInstanceData in pairs(componentGroupsInstanceData:GetChildren()) do
            local componentGroupName = componentGroupInstanceData.Name

            table.insert(componentGroupData, componentGroupName)
        end
    end


    return componentData, componentGroupData
end


local function RemoveChildIfFound(instance, childName)
    local child = instance:FindFirstChild(childName)

    if (child ~= nil) then
        child:Destroy()
    end
end


function EntityBuilder:RemoveComponentsDataFromInstance(instanceData)
    RemoveChildIfFound(instanceData, COMPONENTS_INSTANCE_DATA_NAME)
    RemoveChildIfFound(instanceData, COMPONENTS_MODULE_DATA_NAME)
    RemoveChildIfFound(instanceData, COMPONENT_GROUPS_INSTANCE_DATA_NAME)
end


--- Creates
-- @tparam Dictionary componentData
-- @tparam string[] componentGroupData
-- @treturn ECSComponent[]
function EntityBuilder:CreateComponentsFromData(componentData, componentGroupData)
    componentGroupData = componentGroupData or {}

    assert(type(componentData) == "table")
    assert(type(componentGroupData) == "table")

    -- do componentGroupData
    for _, componentGroupName in pairs(componentGroupData) do
        assert(type(componentGroupName) == "string", "Arg [2] should be a string []!")

        local componentGroup = self:GetComponentGroup(componentGroupName)

        if (componentGroup ~= nil) then
            local componentList = componentGroup:GetComponentList()

            for _, componentName in pairs(componentList) do
                if (componentData[componentName] == nil) then
                    componentData[componentName] = {}
                end
            end
        end
    end

    -- create components
    local newComponents = {}

    for componentName, data in pairs(componentData) do
        local componentDesc = self:GetComponentDescription(componentName)

        if (componentDesc ~= nil) then
            local newComponent = componentDesc:Build(data)

            table.insert(newComponents, newComponent)
        end
    end

    return newComponents
end


function EntityBuilder:MergeComponentData(mainComponentData, otherComponentData)
    for componentName, componentData in pairs(otherComponentData) do
        local currentComponentData = mainComponentData[componentName]
        if (currentComponentData == nil) then
            mainComponentData[componentName] = componentData
        else
            mainComponentData[componentName] = TableMerge(currentComponentData, componentData)
        end
    end

    return mainComponentData
end


--- Creates an Entity from an Instance with components define in it's data
-- @tparam Instance instanceData
-- @treturn ECSEntity
function EntityBuilder:Build(instanceData, componentData)
    assert(typeof(instanceData) == "Instance", "Arg [1] is not an Instance!")

    componentData = componentData or {}
    assert(type(componentData) == "table", "Arg [2] is not a table!")

    local instanceComponentData, instanceComponentGroupData = self:GetComponentDataFromInstance(instanceData)

    if (componentData ~= nil) then
        self:MergeComponentData(instanceComponentData, componentData)
    end

    local newComponents = self:CreateComponentsFromData(instanceComponentData, instanceComponentGroupData)
    self:RemoveComponentsDataFromInstance(instanceData)

    local newEntity = Entity.new(instanceData)
    newEntity:AddComponents(newComponents)


    return newEntity
end


function EntityBuilder:BuildComponent(componentName, componentData)
    assert(type(componentName) == "string", "Arg [1] is not a string!")

    local componentDesc = self:GetComponentDescription(componentName)
    assert(componentDesc, "Unable to build component with name " .. componentName)

    return componentDesc:Build(componentData)
end


---
-- @tparam Instance sceneRootInstance
-- @treturn ECSEntity[]
function EntityBuilder:BuildScene(sceneRootInstance)
    assert(typeof(sceneRootInstance) == "Instance", "Arg [1] is not an Instance!")

    local sceneEntities = {}

    -- assume root is an entity
    local sceneRootEntity = self:Build(sceneRootInstance)
    table.insert(sceneEntities, sceneRootEntity)

    -- assume all children are entities
    for _, entityInstance in pairs(sceneRootInstance:GetChildren()) do
        local entity = self:Build(entityInstance)
        table.insert(sceneEntities, entity)
    end

    return sceneEntities
end


--- Export an entity's component data to a ModuleScript and return copy
-- Bake?
--
function EntityBuilder:ExportEntityData(entityInstance)
    error("Unimplemented!")

    -- Instances are converted to paths from ModuleScript
        -- What if their parent is nil?
            -- Assume it will be set to default value and set to nil


end


--- Export scene data as a module script and scene model package
--
function EntityBuilder:ExportSceneData(sceneRootInstance)
    error("Unimplemented!")
end


return EntityBuilder