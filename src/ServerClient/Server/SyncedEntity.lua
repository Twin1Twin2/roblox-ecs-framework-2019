---
--

local root = script:FindFirstAncestor("ServerClient").Parent
local ECSEntity = require(root.ECSEntity)

local SyncComponent = require(script.Parent.SyncComponent)


local SyncedEntity = {
    ClassName = "SyncedEntity";
}

SyncedEntity.__index = SyncedEntity
setmetatable(SyncedEntity, ECSEntity)


function SyncedEntity.new(entityInstance)
    local self = setmetatable(ECSEntity.new(entityInstance), SyncedEntity)

    self:AddComponent(SyncComponent:Build())


    return self
end


function SyncedEntity:SetComponentAccessType(componentName, componentAccessType)

end


function SyncedEntity:AddComponent(component, componentAccessType)

end


function SyncedEntity:Add()
    -- builder
end


return SyncedEntity