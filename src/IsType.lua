--- Moved type checking functions to here to prevent infinite loops when requiring modules
--

local IsType = {}


IsType.Entity = function(self)
    return self._IsEntity == true
end


IsType.EntityManager = function(self)
    return self._IsEntityManager == true
end


IsType.EntityTable = function(self)
    return self._IsEntityTable == true
end


IsType.EntityBuilder = function(self)
    return self._IsEntityBuilder == true
end


IsType.Component = function(self)
    return self._IsComponent == true
end


IsType.ComponentDescription = function(self)
    return self._IsComponentDescription == true
end


IsType.ComponentGroup = function(self)
    return self._IsComponentGroup == true
end


IsType.ComponentRequirement = function(self)
    return self._IsComponentRequirement == true
end


IsType.System = function(self)
    return self._IsSystem == true
end


IsType.SystemUpdater = function(self)
    return self._IsComponentDescription == true
end


IsType.SystemUpdaterBuilder = function(self)
    return self._IsSystemUpdaterBuilder == true
end


IsType.World = function(self)
    return self._IsWorld == true
end


IsType.Engine_Server = function(self)
    return self._IsEngine_Server == true
end


IsType.EngineConfiguration_Server = function(self)
    return self._IsEngineConfiguration_Server == true
end


IsType.Engine_Client = function(self)
    return self._IsEngine_Client == true
end


IsType.EngineConfiguration_Client = function(self)
    return self._IsEngineConfiguration_Client == true
end


return IsType