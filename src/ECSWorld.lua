--- Manages entities and systems
-- Notifies systems when an Entity is added/removed or it's components change

local Managers = script.Parent.Managers

local EntityManager = require(Managers.EntityManager)
local SystemManager = require(Managers.SystemManager)

local IsType = require(script.Parent.IsType)


local ECSWorld = {
    ClassName = "ECSWorld";
}

ECSWorld.__index = ECSWorld

ECSWorld.IsType = IsType.World


function ECSWorld.new(name)
    name = name or "ECS_WORLD"
    assert(type(name) == "string", "Arg [1] is not a string!")

    local self = setmetatable({}, ECSWorld)

    self._IsWorld = true

    self.Name = name

    self.EntityManager = EntityManager.new(self)
    self.SystemManager = SystemManager.new(self, self.EntityManager)


    return self
end


--- Deconstructor
function ECSWorld:Destroy()
    setmetatable(self, nil)
end


--- Adds an Entity to this World
-- @tparam ECSEntity entity
-- @treturn self
function ECSWorld:AddEntity(entity)
    self.EntityManager:Add(entity)

    return self
end


--- Removes an Entity from this World. Entity is NOT destroyed
-- @tparam ECSEntity entity
-- @treturn self
function ECSWorld:RemoveEntity(entity)
    self.EntityManager:Remove(entity)

    return self
end


--- Adds a System to this World
-- @tparam ECSSystem system
-- @treturn self
function ECSWorld:AddSystem(system)
    self.SystemManager:Add(system)

    return self
end


--- Removes a System from this World
-- @tparam ECSSystem system
-- @treturn self
function ECSWorld:RemoveSystem(system)
    self.SystemManager:Remove(system)

    return self
end


return ECSWorld