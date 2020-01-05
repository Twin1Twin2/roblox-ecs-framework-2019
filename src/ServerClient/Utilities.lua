---
--

local Utilities = {}

local SYNC_EVENTS = {   -- move to a module
    ENTITY_ADDED = 1;
    ENTITY_REMOVED = 2;
    ENTITY_ADD_COMPONENTS = 3;
    ENTITY_REMOVE_COMPONENTS = 4;
    COMPONENT_UPDATE = 5;
    PLAYER_READY = 6;
}

Utilities.SYNC_EVENTS = SYNC_EVENTS

local ACCESS_TYPE = {
    NONE = 0;
    READ_ONLY = 1;
    READ_WRITE = 2;
    SERVER_ONLY = 3;
}

Utilities.ACCESS_TYPE = ACCESS_TYPE

local ACCESS_TYPE_READ_WRITE = ACCESS_TYPE.READ_WRITE
local ACCESS_TYPE_READ_ONLY = ACCESS_TYPE.READ_ONLY

Utilities.IsReadAccessType = function(accessType)
    return accessType == ACCESS_TYPE_READ_WRITE
        or accessType == ACCESS_TYPE_READ_ONLY
end


Utilities.IsPlayer = function(object)
    return typeof(object) == "Instance" and object:IsA("Player")
end


return Utilities