
local Entity = require(script.Parent.ECSEntity)

local IsType = require(script.Parent.IsType)
local IsEntity = IsType.Entity

local function GetOrCreateEntity(entity)
    if (typeof(entity) == "Instance" or entity == nil) then
        return Entity.new(entity)
    end

    assert(IsEntity(entity), "Arg [1] is not an Entity, an Instance, or nil!")
    return entity
end


return GetOrCreateEntity