--- ComponentGroup
--

local IsType = require(script.Parent.IsType)
local IsComponentGroup = IsType.ComponentGroup
local IsComponentDescription = IsType.ComponentDescription

local Table = require(script.Parent.Table)
local TableContains = Table.Contains


local ECSComponentGroup = {
    ClassName = "ECSComponentGroup";
}

ECSComponentGroup.__index = ECSComponentGroup

ECSComponentGroup.IsType = IsComponentGroup


function ECSComponentGroup.new(name, components)
    assert(type(name) == "string", "Arg [1] is not a string!")

    local self = setmetatable({}, ECSComponentGroup)

    self.Name = name
    self.Components = {}

    self._IsComponentGroup = true

    if (type(components) == "table") then
        self:AddFromList(components)
    end


    return self
end


function ECSComponentGroup:Destroy()
    self.Components = nil

    setmetatable(self, nil)
end


function ECSComponentGroup:GetComponentList()
    return self.Components  --should this be copied?
end


function ECSComponentGroup:EntityBelongs(entity)
    return #self.Components > 0 and entity:HasComponents(self.Components)
end


local function AddComponentNamesToList(componentNames, list)
    for index, component in pairs(componentNames) do
        if (IsComponentGroup(component) == true) then
            AddComponentNamesToList(component:GetComponentList(), list)
        end

        local componentName = nil

        if (IsComponentDescription(component) == true) then
            componentName = component.ComponentName
        elseif (component == true) then
            componentName = index
        elseif (type(component) == "string") then
            componentName = component
        end

        if (componentName ~= nil) then
            if (TableContains(list, componentName) == false) then
                table.insert(list, componentName)
            end
        end
    end
end


function ECSComponentGroup:Add(...)
    return self:AddFromList({...})
end


function ECSComponentGroup:AddFromList(list)
    assert(type(list) == "table")
    AddComponentNamesToList(list, self.Components)

    return self
end


return ECSComponentGroup