--- Manages Systems
--

local IsType = require(script.Parent.Parent.IsType)
local IsWorld = IsType.World
local IsEntityManager = IsType.EntityManager

local Table = require(script.Parent.Parent.Table)
local TableGetIndex = Table.GetIndex

local SystemManager = {
    ClassName = "SystemManager";
}

SystemManager.__index = SystemManager

SystemManager.IsType = IsType.SystemManager


function SystemManager.new(world, entityManager)
    assert(IsWorld(world), "Arg [1] is not an ECSWorld!")
    assert(IsEntityManager(entityManager), "Arg [2] is not an EntityManager!")

    local self = setmetatable({}, SystemManager)

    self._IsSystemManager = true

    self.World = world

    self.EntityManager = entityManager
    self.Systems = {}

    entityManager.OnEntityAdded:Connect(function(entity)
        self:EntityChanged(entity)
    end)

    entityManager.OnEntityRemoved:Connect(function(entity)
        self:EntityRemoved(entity)
    end)

    entityManager.OnEntityComponentsAdded:Connect(function(entity)
        self:EntityChanged(entity)
    end)

    entityManager.OnEntityComponentsRemoved:Connect(function(entity)
        self:EntityChanged(entity)
    end)


    return self
end


function SystemManager:Destroy()

end


--- Called on Entity's components changed
--
function SystemManager:EntityChanged(entity)
    for _, system in pairs(self.Systems) do
        local componentRequirement = system.ComponentRequirement
        local entityTable = system.EntityTable

        local doesBelong = componentRequirement:EntityBelongs(entity)

        if (doesBelong == true) then
            entityTable:Insert(entity)
        else
            entityTable:Remove(entity)
        end
    end
end


--- Called on Entity removed from EntityManager
--
function SystemManager:EntityRemoved(entity)
    for _, system in pairs(self.Systems) do
        local entityTable = system.EntityTable
        entityTable:Remove(entity)
    end
end


---
-- @tparam ECSSystem system
function SystemManager:Add(system)
    table.insert(self.Systems, system)

    system:AddToWorld(self.World)
end


---
-- @tparam ECSSystem system
function SystemManager:Remove(system)
    local index = TableGetIndex(self.Table, system)

    if (index ~= nil) then
        table.remove(self.Systems, index)
        system:RemoveFromWorld(self.World)
    end
end


return SystemManager