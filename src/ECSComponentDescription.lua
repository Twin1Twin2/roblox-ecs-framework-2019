--- Describes how a Component is structured
--

local ECSComponent = require(script.Parent.ECSComponent)

local IsType = require(script.Parent.IsType)
local IsComponent = IsType.Component

local Table = require(script.Parent.Table)
local TableCopy = Table.Copy


local ECSComponentDescription = {
    ClassName = "ECSComponentDescription";
}

ECSComponentDescription.__index = ECSComponentDescription

ECSComponentDescription.IsType = IsType.ComponentDescription


--- Creates a new ComponentDescription
-- @tparam string name
function ECSComponentDescription.new(name)
    assert(type(name) == "string", "Arg [1] is not a string!")

    local self = setmetatable({}, ECSComponentDescription)

    self._IsComponentDescription = true

    self.Name = name

    self.Fields = {}
    self.Defaults = {}

    self.CreateComponent = function(component, data)
        self:SetComponentData(component, data)
    end
    self.InitializeComponent = function() end
    self.DestroyComponent = function() end


    return self
end


function ECSComponentDescription:Clone()
    local newComponentDescription = ECSComponentDescription.new(self.Name)

    newComponentDescription.Fields = TableCopy(self.Fields)
    newComponentDescription.Defaults = TableCopy(self.Defaults)

    newComponentDescription.CreateComponent = self.CreateComponent
    newComponentDescription.InitializeComponent = self.InitializeComponent
    newComponentDescription.DestroyComponent = self.DestroyComponent


    return newComponentDescription
end


--- Builds a new Component using this Description
-- @treturn ECSComponent
function ECSComponentDescription:Build(data)
    return ECSComponent.new(self, data)
end


--- Gets the data of the given component
-- @tparam ECSComponent
-- @treturn table
function ECSComponentDescription:GetComponentData(component)
    assert(IsComponent(component), "Arg [1] is not a ECSComponent")

    local data = {}

    for _, fieldName in pairs(self.Fields) do
        data[fieldName] = component[fieldName]
    end

    return data
end


--- Fills out the data of the given component
-- @tparam ECSComponent
-- @tparam table
function ECSComponentDescription:SetComponentData(component, data)
    assert(IsComponent(component), "Arg [1] is not a ECSComponent")
    assert(type(data) == "table", "Arg [2] is not a Table!")

    for _, fieldName in pairs(self.Fields) do
        local newData = data[fieldName]

        if (newData ~= nil) then
            component[fieldName] = newData
        end
    end
end


return ECSComponentDescription