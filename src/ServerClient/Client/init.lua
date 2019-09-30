
local Utilities = require(script.Parent.Utilities)

local ECSClientFramework = {}

ECSClientFramework.Engine = require(script.Engine)
ECSClientFramework.EngineConfiguration = require(script.EngineConfiguration)
ECSClientFramework.SetupEngineConfiguration = require(script.SetupEngineConfiguration)


local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_NONE = ACCESS_TYPE.NONE
local ACCESS_TYPE_READ_ONLY = ACCESS_TYPE.READ_ONLY
local ACCESS_TYPE_READ_WRITE = ACCESS_TYPE.READ_WRITE

ECSClientFramework.ACCESS_TYPE = ACCESS_TYPE


local function GetSyncAccessToComponent(entity, componentName)
    local syncComponent, component = entity:GetComponents("SyncComponent", componentName)

    if (syncComponent == nil or component == nil) then
        return ACCESS_TYPE_NONE
    end

    local accessData = syncComponent.AccessData
    local accessType = accessData[componentName]

    return accessType or ACCESS_TYPE_NONE
end

ECSClientFramework.GetSyncAccessToComponent = GetSyncAccessToComponent


local function CheckHasAccessType(componentName, accessType)
    return function(entity)
        local componentAccessType = GetSyncAccessToComponent(entity, componentName)

        return componentAccessType == accessType
    end
end


ECSClientFramework.ReadRequirement = function(componentName)
    assert(type(componentName) == "string", "Arg [1] is not a string!")

    return function(entity)
        local accessType = GetSyncAccessToComponent(entity, componentName)

        return (accessType == ACCESS_TYPE_READ_ONLY
                or accessType == ACCESS_TYPE_READ_WRITE)
    end
end


ECSClientFramework.ReadOnlyRequirement = function(componentName)
    assert(type(componentName) == "string", "Arg [1] is not a string!")
    return CheckHasAccessType(componentName, ACCESS_TYPE_READ_ONLY)
end


ECSClientFramework.ReadWriteRequirement = function(componentName)
    assert(type(componentName) == "string", "Arg [1] is not a string!")
    return CheckHasAccessType(componentName, ACCESS_TYPE_READ_WRITE)
end


return ECSClientFramework