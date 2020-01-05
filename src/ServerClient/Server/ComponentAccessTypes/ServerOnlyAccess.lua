
local ComponentAccessType = require(script.Parent.ComponentAccessType)

local Utilities = require(script:FindFirstAncestor("ServerClient").Utilities)

local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_SERVER_ONLY = ACCESS_TYPE.SERVER_ONLY

local ServerOnlyAccess = {
    ClassName = "ServerOnlyAccess";
}

ServerOnlyAccess.__index = ServerOnlyAccess
setmetatable(ServerOnlyAccess, ComponentAccessType)


function ServerOnlyAccess.new()
    local self = setmetatable(ComponentAccessType.new(ACCESS_TYPE_SERVER_ONLY), ServerOnlyAccess)

    self.IsServerOnly = true


    return self
end


function ServerOnlyAccess:Destroy()
    self.Owner = nil
    setmetatable(self, nil)
end


return ServerOnlyAccess