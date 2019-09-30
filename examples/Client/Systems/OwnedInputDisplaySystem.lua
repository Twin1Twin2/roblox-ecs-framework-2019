--- OwnedInputDisplaySystem
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local System = ECSFramework.System

local ClientFramework = ECSFramework.Client
local GetSyncAccessToComponent = ClientFramework.GetSyncAccessToComponent
local ReadRequirement = ClientFramework.ReadRequirement

local ACCESS_TYPE = ClientFramework.ACCESS_TYPE


local OwnedInputDisplaySystem = {
    ClassName = "OwnedInputDisplaySystem";
}

OwnedInputDisplaySystem.__index = OwnedInputDisplaySystem
setmetatable(OwnedInputDisplaySystem, System)


function OwnedInputDisplaySystem.new()
    local self = setmetatable(System.new(), OwnedInputDisplaySystem)

    self.ComponentRequirement
        :WithFunction(ClientFramework.ReadOnlyRequirement("OwnerComponent"))
        :WithFunction(ReadRequirement("OwnedInputComponent"))

    self.EntityTable.OnInserted:Connect(function(entity)
        print("OwnedInputDisplaySystem - Entity Added!")
    end)


    return self
end


function OwnedInputDisplaySystem:UpdateEntity(entity)
    local inputComponent = entity:GetComponent("OwnedInputComponent")
    local syncAccess = GetSyncAccessToComponent(entity, "OwnedInputComponent")

    local ownerComponent = entity:GetComponent("OwnerComponent")

    if (syncAccess == ACCESS_TYPE.READ_ONLY) then
        print("Owner = " .. ownerComponent.Owner.Name .. "; Input = " .. tostring(inputComponent.Input))
    elseif (syncAccess == ACCESS_TYPE.READ_WRITE) then
        print("Input = " .. tostring(inputComponent.Input))
    end
end


function OwnedInputDisplaySystem:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


return OwnedInputDisplaySystem