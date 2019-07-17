--- EntityTable
--

local IsType = require(script.Parent.IsType)

local Table = require(script.Parent.Table)
local TableCopy = Table.Copy
local TableContains = Table.Contains
local TableGetIndex = Table.GetIndex

local Signal = require("Signal")


local EntityTable = {
    ClassName = "EntityTable";
}

EntityTable.__index = EntityTable

EntityTable.IsType = IsType.EntityTable


function EntityTable.new()
    local self = setmetatable({}, EntityTable)

    self._IsEntityTable = true

    self.Table = {}

    self._IsLocked = false

    self._EntitiesToInsert = {}
    self._EntitiesToRemove = {}

    self.OnInserted = Signal.new()
    self.OnRemoved = Signal.new()


    return self
end


--- Deconstructor
function EntityTable:Destroy()
    self._IsLocked = true

    self.Table = nil

    self._EntitiesToInsert = nil
    self._EntitiesToRemove = nil

    self.OnInserted:Destroy()
    self.OnRemoved:Destroy()

    setmetatable(self, nil)
end


function EntityTable:_Insert(entity)
    table.insert(self.Table, entity)
    self.OnInserted:Fire(entity)
end


function EntityTable:_Remove(entity)
    local index = TableGetIndex(self.Table, entity)

    if (index ~= nil) then
        table.remove(self.Table, index)
        self.OnRemoved:Fire(entity)
    end
end


--- Gets a copy of the table
-- @treturn ECSEntity[]
function EntityTable:GetCopy()
    return TableCopy(self.Table)
end


--- Locks the table
-- @treturn ECSEntity[]
function EntityTable:Lock()
    if (self._IsLocked == false) then
        self._IsLocked = true
    end

    return self.Table
end


--- Unlocks the table
--
function EntityTable:Unlock()
    if (self._IsLocked == false) then
        return
    end

    -- check if a change was made while locked
    local entitiesToInsert = self._EntitiesToInsert
    local entitiesToRemove = self._EntitiesToRemove

    self._EntitiesToInsert = {}
    self._EntitiesToRemove = {}

    self._IsLocked = false


    if (#entitiesToInsert > 0 or #entitiesToRemove > 0) then
        for _, value in pairs(entitiesToInsert) do
            self:_Insert(value)
        end

        for _, value in pairs(entitiesToRemove) do
            self:_Remove(value)
        end
    end
end


function EntityTable:Insert(entity)
    if (TableContains(self.Table, entity) == true) then
        return
    end

    if (self._IsLocked == true) then
        if (TableContains(self._EntitiesToInsert, entity) == false) then
            table.insert(self._EntitiesToInsert, entity)
        end
    else
        self:_Insert(entity)
    end
end


--- Removes an Entity from the table
-- @tparam ECSEntity entity
function EntityTable:Remove(entity)
    if (TableContains(self.Table, entity) == false) then
        return
    end

    if (self._IsLocked == true) then
        if (TableContains(self._EntitiesToRemove, entity) == false) then
            table.insert(self._EntitiesToRemove, entity)
        end
    else
        self:_Remove(entity)
    end
end


return EntityTable