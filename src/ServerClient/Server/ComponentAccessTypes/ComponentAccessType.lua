
local Utilities = require(script:FindFirstAncestor("ServerClient").Utilities)
local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_NONE = ACCESS_TYPE.NONE

local ComponentAccessType = {
    ClassName = "ComponentAccessType";
}

ComponentAccessType.__index = ComponentAccessType


function ComponentAccessType.new(accessType)
    accessType = accessType or ACCESS_TYPE_NONE
    assert(type(accessType) == "number")

    local self = setmetatable({}, ComponentAccessType)

    self._IsComponentAccessType = true

    self.DefaultAccessType = accessType


    return self
end


function ComponentAccessType:Destroy()
    setmetatable(self, nil)
end


function ComponentAccessType:GetForPlayer(player)
    return self.DefaultAccessType
end


return ComponentAccessType