--- Struct for creating an ECSEngine
--

local root = script.Parent.Parent.Parent
local EntityBuilder = require(root.EntityBuilder)
local SystemUpdaterBuilder = require(root.SystemUpdaterBuilder)

local IsType = require(root.IsType)


local EngineConfiguration_Server = {
    ClassName = "EngineConfiguration_Server";
}

EngineConfiguration_Server.__index = EngineConfiguration_Server

EngineConfiguration_Server.IsType = IsType.EngineConfiguration_Server


function EngineConfiguration_Server.new()
    local self = setmetatable({}, EngineConfiguration_Server)

    self._IsEngineConfiguration_Server = true

    self.Name = "ECS_Server"

    self.EntityBuilder = EntityBuilder.new()

    self.Stepped = SystemUpdaterBuilder.new()
    self.Heartbeat = SystemUpdaterBuilder.new()
    self.NoUpdate = SystemUpdaterBuilder.new()


    return self
end


return EngineConfiguration_Server