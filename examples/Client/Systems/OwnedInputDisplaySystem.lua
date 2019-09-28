--- OwnedInputDisplaySystem
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local System = ECSFramework.System

local ClientFramework = ECSFramework.Client
local ReadRequirement = ClientFramework.ReadRequirement


local OwnedInputDisplaySystem = {
    ClassName = "OwnedInputDisplaySystem";
}

OwnedInputDisplaySystem.__index = OwnedInputDisplaySystem
setmetatable(OwnedInputDisplaySystem, System)


function OwnedInputDisplaySystem.new()
    local self = setmetatable(System.new(), OwnedInputDisplaySystem)

    self.ComponentRequirement
        :WithFunction(ReadRequirement("OwnedInputComponent"))

    self.EntityTable.OnInserted:Connect(function(entity)
        print("OwnedInputDisplaySystem - Entity Added!")
    end)


    return self
end


function OwnedInputDisplaySystem:UpdateEntity(entity)
    local inputComponent = entity:GetComponent("OwnedInputComponent")

    print(inputComponent.Input)
end


function OwnedInputDisplaySystem:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


return OwnedInputDisplaySystem