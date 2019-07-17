--- Updates a list of systems in order
--

local IsType = require(script.Parent.IsType)
local IsSystem = IsType.System
local IsWorld = IsType.World

local Table = require(script.Parent.Table)
local TableGetIndex = Table.GetIndex


local SystemUpdater = {
    ClassName = "SystemUpdater";
}

SystemUpdater.__index = SystemUpdater

SystemUpdater.IsType = IsType.SystemUpdater


function SystemUpdater.new(world)
    assert(IsWorld(world), "Arg [1] is not an ECSWorld!")

    local self = setmetatable({}, SystemUpdater)

    self._IsSystemUpdater = true

    self.World = world
    self.Systems = {}


    return self
end


function SystemUpdater:Update(world)
    for _, system in ipairs(self.Systems) do
        system:DoUpdate()
    end
end


function SystemUpdater:Add(system)
    assert(IsSystem(system), "Arg [1] is not a System")

    self.World:AddSystem(system)
    table.insert(self.Systems, system)
end


function SystemUpdater:Remove(system)
    assert(IsSystem(system), "Arg [1] is not a System")

    local index = TableGetIndex(self.Table, system)

    if (index ~= nil) then
        table.remove(self.Systems, index)
        self.OnRemoved:Fire(system)
    end

    self.World:RemoveSystem(system)
end


return SystemUpdater