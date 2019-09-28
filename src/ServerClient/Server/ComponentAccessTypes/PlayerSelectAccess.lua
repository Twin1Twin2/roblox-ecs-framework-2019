
local ComponentAccessType = require(script.Parent.ComponentAccessType)

local Utilities = require(script:FindFirstAncestor("ServerClient").Utilities)

local IsPlayer = Utilities.IsPlayer

local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_READ_ONLY = ACCESS_TYPE.READ_ONLY


local PlayerSelectAccess = {
    ClassName = "PlayerSelectAccess";
}

PlayerSelectAccess.__index = PlayerSelectAccess
setmetatable(PlayerSelectAccess, ComponentAccessType)


function PlayerSelectAccess.new(players, selectAccessType, defaultAccessType)
    assert(type(players) == "table")

    selectAccessType = selectAccessType or ACCESS_TYPE_READ_ONLY
    assert(type(selectAccessType) == "number")

    local self = setmetatable(ComponentAccessType.new(defaultAccessType), PlayerSelectAccess)

    self.Players = players
    self.SelectAccessType = selectAccessType


    return self
end


function PlayerSelectAccess:Destroy()
    self.Players = nil

    setmetatable(self, nil)
end


function PlayerSelectAccess:GetForPlayer(player)
    assert(IsPlayer(player), "Arg [1] is not a Player!")

    for _, otherPlayer in pairs(self.Players) do
        if (player == otherPlayer) then
            return self.SelectAccessType
        end
    end

    return self.DefaultAccessType
end


return PlayerSelectAccess