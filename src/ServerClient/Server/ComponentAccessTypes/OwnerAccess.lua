
local ComponentAccessType = require(script.Parent.ComponentAccessType)

local Utilities = require(script:FindFirstAncestor("ServerClient").Utilities)

local IsPlayer = Utilities.IsPlayer

local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_READ_WRITE = ACCESS_TYPE.READ_WRITE

local OwnerAccess = {
    ClassName = "OwnerAccess";
}

OwnerAccess.__index = OwnerAccess
setmetatable(OwnerAccess, ComponentAccessType)


function OwnerAccess.new(owner, ownerAccessType, defaultAccessType)
    assert(IsPlayer(owner), "Arg [1] is not a player!")

    ownerAccessType = ownerAccessType or ACCESS_TYPE_READ_WRITE
    assert(type(ownerAccessType) == "number")

    local self = setmetatable(ComponentAccessType.new(defaultAccessType), OwnerAccess)

    self.Owner = owner
    self.OwnerAccessType = ownerAccessType


    return self
end


function OwnerAccess:Destroy()
    self.Owner = nil
    setmetatable(self, nil)
end


function OwnerAccess:GetForPlayer(player)
    assert(IsPlayer(player))

    if (player == self.Owner) then
        return self.OwnerAccessType
    end

    return self.DefaultAccessType
end


return OwnerAccess