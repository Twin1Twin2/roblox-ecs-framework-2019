--- Struct for creating an ECSEngine
--

local EntityBuilder = require(script.Parent.EntityBuilder)
local SystemUpdaterBuilder = require(script.Parent.SystemUpdaterBuilder)

local IsType = require(script.Parent.IsType)


local EngineConfiguration = {
    ClassName = "EngineConfiguration";
}

EngineConfiguration.__index = EngineConfiguration

EngineConfiguration.IsType = IsType.EngineConfiguration


function EngineConfiguration.new()
    local self = setmetatable({}, EngineConfiguration)

    self._IsEngineConfiguration = true

    self.EntityBuilder = EntityBuilder.new()

    self.RenderStepped = SystemUpdaterBuilder.new();
    self.Stepped = SystemUpdaterBuilder.new();
    self.Heartbeat = SystemUpdaterBuilder.new();
    self.NoUpdate = SystemUpdaterBuilder.new();


    return self
end


return EngineConfiguration