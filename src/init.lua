--- Initializes all of the classes in the framework
--

local ECSFramework = {}


ECSFramework.Entity = require(script.ECSEntity)
ECSFramework.EntityBuilder = require(script.EntityBuilder)
ECSFramework.EntityTable = require(script.EntityTable)

ECSFramework.Component = require(script.ECSComponent)
ECSFramework.ComponentDescription = require(script.ECSComponentDescription)
ECSFramework.ComponentGroup = require(script.ECSComponentGroup)
ECSFramework.ComponentRequirement = require(script.ECSComponentRequirement)

ECSFramework.System = require(script.ECSSystem)
ECSFramework.SystemUpdater = require(script.SystemUpdater)
ECSFramework.SystemUpdaterBuilder = require(script.SystemUpdaterBuilder)

ECSFramework.World = require(script.ECSWorld)

ECSFramework.Server = require(script.ServerClient.Server)
ECSFramework.Client = require(script.ServerClient.Client)


return ECSFramework