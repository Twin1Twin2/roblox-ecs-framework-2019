--- OwnedInputUpdateSystem
-- Updates all other clients

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local System = ECSFramework.System

local ClientFramework = ECSFramework.Client
local ReadWriteRequirement = ClientFramework.ReadWriteRequirement

local UserInputService = game:GetService("UserInputService")


local OwnedInputUpdateSystem = {
    ClassName = "OwnedInputUpdateSystem";
}

OwnedInputUpdateSystem.__index = OwnedInputUpdateSystem
setmetatable(OwnedInputUpdateSystem, System)


function OwnedInputUpdateSystem.new()
    local self = setmetatable(System.new(), OwnedInputUpdateSystem)

    self.ComponentRequirement
        :WithFunction(ReadWriteRequirement("OwnedInputComponent")) -- only update if owned (ReadWrite)

    self.EntityTable.OnInserted:Connect(function(entity)
        print("OwnedInputUpdateSystem - Entity Added!")
    end)


    return self
end


function OwnedInputUpdateSystem:AddedToWorld(world)

end


function OwnedInputUpdateSystem:RemovedFromWorld(world)

end


function OwnedInputUpdateSystem:EntityAdded(entity)

end


function OwnedInputUpdateSystem:EntityRemoved(entity)

end


function OwnedInputUpdateSystem:UpdateEntity(entity)
    local inputComponent = entity:GetComponent("OwnedInputComponent")

    inputComponent.Input = UserInputService:IsKeyDown(Enum.KeyCode.E)

    -- entity:AddComponent(inputComponent) -- ?

end


function OwnedInputUpdateSystem:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


return OwnedInputUpdateSystem