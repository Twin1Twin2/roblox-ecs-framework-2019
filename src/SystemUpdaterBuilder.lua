---
--

local SystemUpdater = require(script.Parent.SystemUpdater)

local IsType = require(script.Parent.IsType)
local IsSystem = IsType.System
local IsWorld = IsType.World

local Table = require(script.Parent.Table)
local TableContains = Table.Contains


local SystemUpdaterBuilder = {
    ClassName = "SystemUpdaterBuilder";
}

SystemUpdaterBuilder.__index = SystemUpdaterBuilder

SystemUpdaterBuilder.IsType = IsType.SystemUpdaterBuilder


function SystemUpdaterBuilder.new()
    local self = setmetatable({}, SystemUpdaterBuilder)

    self._IsSystemUpdaterBuilder = true

    self.Systems = {}


    return self
end


function SystemUpdaterBuilder:Build(world)
    assert(IsWorld(world), "Arg [1] is not an ECSWorld!")

    local newSystemUpdater = SystemUpdater.new(world)

    for _, system in pairs(self.Systems) do
        newSystemUpdater:Add(system)
    end


    return newSystemUpdater
end


function SystemUpdaterBuilder:With(system)
    assert(IsSystem(system), "Arg [1] is not an ECSSystem!")

    if (TableContains(self.Systems, system) == false) then
        table.insert(self.Systems, system)
    end

    return self
end


return SystemUpdaterBuilder