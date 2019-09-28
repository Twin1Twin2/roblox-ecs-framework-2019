--- ECS Component
--

local Table = require(script.Parent.Table)
local DeepCopy = Table.DeepCopy

local IsType = require(script.Parent.IsType)
local IsComponentDescription = IsType.ComponentDescription


local ECSComponent = {
    ClassName = "ECSComponent";
}

ECSComponent.__index = ECSComponent

ECSComponent.IsType = IsType.Component


--- Creates a new Component
-- @tparam ECSComponentDescription
-- @tparam table data
-- @treturn ECSComponent
function ECSComponent.new(componentDesc, data)
    assert(IsComponentDescription(componentDesc) == true, "Arg [1] is not an ECSComponentDescription!")

    data = data or {}
    assert(type(data) == "table", "Arg [2] is not a table!")

    local self = setmetatable({}, ECSComponent)

    self._IsComponent = true

    self._COMPONENT_DESCRIPTION = componentDesc
    self._COMPONENT_NAME = componentDesc.Name

    self._IsInitialized = false

    -- fill out default values
    -- AltMerge(self, componentDesc.Data)
    local defaults = componentDesc.Defaults

    for _, fieldName in pairs(componentDesc.Fields) do
        self[fieldName] = DeepCopy(defaults[fieldName])
    end

    -- do extra initialization in comp desc
    local newSelf = componentDesc.CreateComponent(self, data)
    self = newSelf or self


    return self
end


--- Destroys this object
function ECSComponent:Destroy()
    self._COMPONENT_DESCRIPTION.DestroyComponent(self)

    setmetatable(self, nil)
end


--- Initializes this component
-- Called by the entity
-- @tparam ECSEntity entity
function ECSComponent:Initialize(entity)
    if (self._IsInitialized == false) then
        self._IsInitialized = true
        self._COMPONENT_DESCRIPTION.InitializeComponent(self, entity)
    end
end


function ECSComponent:CopyData()
    return self._COMPONENT_DESCRIPTION:GetComponentData(self)
end


function ECSComponent:GetSyncData()
    return self._COMPONENT_DESCRIPTION.GetSyncData(self)
end


return ECSComponent