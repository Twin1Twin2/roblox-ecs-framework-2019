--- System
--

local ECSComponentRequirement = require(script.Parent.ECSComponentRequirement)

local EntityTable = require(script.Parent.EntityTable)

local IsType = require(script.Parent.IsType)


local ECSSystem = {
    ClassName = "ECSSystem";
}

ECSSystem.__index = ECSSystem

ECSSystem.IsType = IsType.System


--- Creates a new ECSSystem
function ECSSystem.new()
    local self = setmetatable({}, ECSSystem)

    self._IsSystem = true

    self.ComponentRequirement = ECSComponentRequirement.new()
    self.World = nil    -- ECSWorld

    self.EntityTable = EntityTable.new()


    return self
end


function ECSSystem:Destroy()
    self.World = nil

    self.ComponentRequirement:Destroy()
    self.ComponentRequirement = nil

    self.EntityTable:Destroy()
    self.EntityTable = nil


    setmetatable(self, nil)
end


function ECSSystem:AddToWorld(world)
    self.World = world
    self:AddedToWorld(self.World)
end


function ECSSystem:RemoveFromWorld()
    self:RemovedFromWorld(self.World)
    self.World = nil
end


--- Does an update
--
function ECSSystem:DoUpdate()
    local entityTable = self.EntityTable
    local entities = entityTable:Lock()

    self:Update(entities)

    entityTable:Unlock()
end


-- Overridable methods

function ECSSystem:AddedToWorld(world)
    -- override
end


function ECSSystem:RemovedFromWorld(world)
    -- override
end


--- Updates the system
function ECSSystem:Update(entities)
    -- override
end


return ECSSystem