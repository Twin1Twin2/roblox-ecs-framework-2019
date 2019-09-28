--- Struct for creating an ECSEngine
--

local root = script.Parent.Parent.Parent
local EntityBuilder = require(root.EntityBuilder)
local SystemUpdaterBuilder = require(root.SystemUpdaterBuilder)

local IsType = require(root.IsType)


local EngineConfiguration_Client = {
    ClassName = "EngineConfiguration_Client";
}

EngineConfiguration_Client.__index = EngineConfiguration_Client

EngineConfiguration_Client.IsType = IsType.EngineConfiguration_Client


function EngineConfiguration_Client.new()
    local self = setmetatable({}, EngineConfiguration_Client)

    self._IsEngineConfiguration_Client = true

    self.Name = "ECS_Client"

    self.EntityBuilder = EntityBuilder.new()

    self.RenderStepped = SystemUpdaterBuilder.new()
    self.Stepped = SystemUpdaterBuilder.new()
    self.Heartbeat = SystemUpdaterBuilder.new()
    self.NoUpdate = SystemUpdaterBuilder.new()


    return self
end


return EngineConfiguration_Client