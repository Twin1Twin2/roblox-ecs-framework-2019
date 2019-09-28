--- ComponentRequirement
--

local IsType = require(script.Parent.IsType)
local IsComponentDescription = IsType.ComponentDescription
local IsComponentGroup = IsType.ComponentGroup

local Table = require(script.Parent.Table)
local TableContains = Table.Contains


local ECSComponentRequirement = {
    ClassName = "ECSComponentRequirement";
}

ECSComponentRequirement.__index = ECSComponentRequirement

ECSComponentRequirement.IsType = IsType.ComponentRequirement


function ECSComponentRequirement.new()
    local self = setmetatable({}, ECSComponentRequirement)

    self._IsComponentRequirement = true

    self.AllList = {}
    self.OneList = {}
    self.ExcludeList = {}
    self.FunctionList = {}


    return self
end


function ECSComponentRequirement:Destroy()
    self.AllList = nil
    self.OneList = nil
    self.ExcludeList = nil
    self.FunctionList = nil

    setmetatable(self, nil)
end


function ECSComponentRequirement:Clone(name)
    local newObject = ECSComponentRequirement.new()

    newObject.Name = name or self.Name
    newObject:Set(self.AllList, self.OneList, self.ExcludeList)


    return newObject
end


local function CopyToList(list, source)
    for _, name in pairs(source) do
        table.insert(list, name)
    end
end


function ECSComponentRequirement:GetComponentList()
    local componentList = {}

    CopyToList(componentList, self.AllList)
    CopyToList(componentList, self.OneList)
    CopyToList(componentList, self.ExcludeList)


    return componentList
end


local function AddNameToListIfNotInOther(instanceName, name, list, listName, otherLists)
    -- make sure it isn't already in the other list
    for otherListName, otherList in pairs(otherLists) do
        if (TableContains(otherList, name) == true) then
            warn("ComponentRequirement - " .. instanceName
                .. ": Unable to add \"" .. name .. "\" to list \""
                .. listName .. "\"! Already in list \""
                .. otherListName .. "\"!")
            return
        end
    end

    if (TableContains(list, name) == false) then
        table.insert(list, name)
    end
end


local function AddComponentNamesToList(instanceName, componentNames, list, listName, otherLists)
    for index, component in pairs(componentNames) do
        if (IsComponentGroup(component) == true) then
            AddComponentNamesToList(instanceName, component:GetComponentList(), list, listName, otherLists)
        end

        local componentName = nil

        if (IsComponentDescription(component) == true) then
            componentName = component.Name
        elseif (component == true) then
            componentName = index
        elseif (type(component) == "string") then
            componentName = component
        end

        if (componentName ~= nil) then
            AddNameToListIfNotInOther(instanceName, componentName, list, listName, otherLists)
        end
    end
end


function ECSComponentRequirement:EntityBelongs(entity)
    local hasChecked = false

    if (#self.FunctionList > 0) then
        for _, func in pairs(self.FunctionList) do
            if (func(entity) == false) then
                return false
            end
        end

        hasChecked = true
    end

    if (#self.ExcludeList > 0) then
        for _, componentName in pairs(self.ExcludeList) do
            if (entity:HasComponent(componentName) == true) then
                return false
            end
        end

        hasChecked = true
    end

    if (#self.AllList > 0) then
        for _, componentName in pairs(self.AllList) do
            if (entity:HasComponent(componentName) == false) then
                return false
            end
        end

        hasChecked = true
    end

    if (#self.OneList > 0) then
        for _, componentName in pairs(self.OneList) do
            if (entity:HasComponent(componentName) == true) then
                return true
            end
        end
    end

    return hasChecked
end


-- Adding/Setting Components


function ECSComponentRequirement:WithFunction(func)
    assert(type(func) == "function", "Arg [1] is not a function!")

    table.insert(self.FunctionList, func)
end


function ECSComponentRequirement:All(...)
    return self:AllFromList({...})
end


function ECSComponentRequirement:AllFromList(list)
    assert(type(list) == "table")
    AddComponentNamesToList(self.Name, list, self.AllList, "All", { Exclude = self.ExcludeList })

    return self     -- for chaining
end


function ECSComponentRequirement:One(...)
    return self:OneFromList({...})
end


function ECSComponentRequirement:OneFromList(list)
    assert(type(list) == "table")
    AddComponentNamesToList(self.Name, list, self.OneList, "One", { Exclude = self.ExcludeList })

    return self     -- for chaining
end


function ECSComponentRequirement:Exclude(...)
    return self:ExcludeFromList({...})
end


function ECSComponentRequirement:ExcludeFromList(list)
    assert(type(list) == "table")
    AddComponentNamesToList(self.Name, list, self.ExcludeList, "Exclude", { All = self.AllList; One = self.OneList; })

    return self     -- for chaining
end


function ECSComponentRequirement:Set(allList, oneList, excludeList)
    self:AllFromList(allList or {}):OneFromList(oneList or {}):ExcludeFromList(excludeList or {})
end


return ECSComponentRequirement