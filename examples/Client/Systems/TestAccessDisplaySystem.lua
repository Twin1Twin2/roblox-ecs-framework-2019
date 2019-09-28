--- TestAccessDisplaySystem
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local System = ECSFramework.System

local ClientFramework = ECSFramework.Client
local ReadRequirement = ClientFramework.ReadRequirement


local TestAccessDisplaySystem = {
    ClassName = "TestAccessDisplaySystem";
}

TestAccessDisplaySystem.__index = TestAccessDisplaySystem
setmetatable(TestAccessDisplaySystem, System)


function TestAccessDisplaySystem.new()
    local self = setmetatable(System.new(), TestAccessDisplaySystem)

    self.ComponentRequirement
        :WithFunction(ReadRequirement("TestAccessComponent"))

    self.EntityTable.OnInserted:Connect(function(entity)
        print("TestAccess Added")
        -- self:EntityAdded(entity)
    end)
    self.EntityTable.OnRemoved:Connect(function(entity)
        print("TestAccess Removed")
        -- self:EntityRemoved(entity)
    end)


    return self
end


function TestAccessDisplaySystem:AddedToWorld(world)

end


function TestAccessDisplaySystem:RemovedFromWorld(world)

end


function TestAccessDisplaySystem:EntityAdded(entity)

end


function TestAccessDisplaySystem:EntityRemoved(entity)

end


function TestAccessDisplaySystem:UpdateEntity(entity)

end


function TestAccessDisplaySystem:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


return TestAccessDisplaySystem