
local Utilities = require(script.Parent.Utilities)

local ECSClientFramework = {}

ECSClientFramework.Engine = require(script.Engine)
ECSClientFramework.EngineConfiguration = require(script.EngineConfiguration)
ECSClientFramework.SetupEngineConfiguration = require(script.SetupEngineConfiguration)


local ACCESS_TYPE = Utilities.ACCESS_TYPE
local ACCESS_TYPE_READ_ONLY = ACCESS_TYPE.READ_ONLY
local ACCESS_TYPE_READ_WRITE = ACCESS_TYPE.READ_WRITE

local function GetSyncAccessToComponent(entity, componentName)
    local syncComponent, component = entity:GetComponents("SyncComponent", componentName)

    if (syncComponent == nil or component == nil) then
        return false, -1
    end

    local accessData = syncComponent.AccessData
    local accessType = accessData[componentName]

    return true, (accessType or -1)
end


local function CheckHasAccessType(componentName, accessType)
    return function(entity)
        local hasSyncAccess, componentAccessType = GetSyncAccessToComponent(entity, componentName)

        return hasSyncAccess == true
            and componentAccessType == accessType
    end
end


ECSClientFramework.ReadRequirement = function(componentName)
    assert(type(componentName) == "string", "Arg [1] is not a string!")

    return function(entity)
        local hasSyncAccess, accessType = GetSyncAccessToComponent(entity, componentName)

        return hasSyncAccess == true
            and (accessType == ACCESS_TYPE_READ_ONLY
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