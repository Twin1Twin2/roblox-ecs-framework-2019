--- ComponentSyncSystem_Server
--

local ECSFramework = require("ECSFramework")
local System = ECSFramework.System


local ComponentSyncSystem_Server = {
    ClassName = "ComponentSyncSystem_Server";
}

ComponentSyncSystem_Server.__index = ComponentSyncSystem_Server
setmetatable(ComponentSyncSystem_Server, System)


function ComponentSyncSystem_Server.new(syncManager)
    local self = setmetatable(System.new(), ComponentSyncSystem_Server)

    self.ComponentRequirement
        :All("SyncComponent")
        :All("ComponentsUpdatedComponent")


    return self
end


function ComponentSyncSystem_Server:UpdateEntity(entity)
    -- check if component has been updated
    -- update clients

    local componentsUpdatedComponent = entity:GetComponent("ComponentsUpdatedComponent")
    local componentsToUpdate = componentsUpdatedComponent.Components

    for _, componentName in pairs(componentsToUpdate) do
        self.SyncManager:ComponentUpdated(entity, componentName)
    end

    entity:RemoveComponent("ComponentsUpdatedComponent")
end


function ComponentSyncSystem_Server:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


return ComponentSyncSystem_Server