--- Describes how a Component is structured
--

local ECSComponent = require(script.Parent.ECSComponent)

local IsType = require(script.Parent.IsType)

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


--- Fills out the data of the given component
--
function ECSComponentDescription:SetComponentData(component, data)
    -- fills out the component with data from data (if it has it)
    for _, fieldName in pairs(self.Fields) do
        local newData = data[fieldName]

        if (newData ~= nil) then
            component[fieldName] = newData
        end
    end
end


return ECSComponentDescription