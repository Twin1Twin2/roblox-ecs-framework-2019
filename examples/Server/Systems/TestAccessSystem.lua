--- TestAccessSystem
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local System = ECSFramework.System

local ECSServerFramework = ECSFramework.Server
local ACCESS_TYPE = ECSServerFramework.ACCESS_TYPE
local SetComponentAccessType = ECSServerFramework.SetComponentAccessType
local ComponentAccessTypes = ECSServerFramework.ComponentAccessTypes
local ComponentAccessType = ComponentAccessTypes.ComponentAccessType


local TestAccessSystem = {
    ClassName = "TestAccessSystem";
}

TestAccessSystem.__index = TestAccessSystem
setmetatable(TestAccessSystem, System)


function TestAccessSystem.new()
    local self = setmetatable(System.new(), TestAccessSystem)

    self.ComponentRequirement
        :All("TestAccessComponent")

    self.EntityTable.OnInserted:Connect(function(entity)
        self:EntityAdded(entity)
    end)
    self.EntityTable.OnRemoved:Connect(function(entity)
        self:EntityRemoved(entity)
    end)
    self.Test = true


    return self
end


function TestAccessSystem:AddedToWorld(world)

end


function TestAccessSystem:RemovedFromWorld(world)

end


function TestAccessSystem:EntityAdded(entity)
    self.IsActive = true

    spawn(function()
        while self.IsActive == true do
            print("Setting to " .. tostring(self.Test))
            self:DoUpdate()
            wait(5)
            self.Test = not self.Test
        end
    end)
end


function TestAccessSystem:EntityRemoved(entity)
    self.IsActive = false
end


function TestAccessSystem:UpdateEntity(entity)
    local accessType = ACCESS_TYPE.READ_ONLY
    if (self.Test == false) then
        accessType = ACCESS_TYPE.NONE
    end

    SetComponentAccessType(entity, "TestAccessComponent", ComponentAccessType.new(accessType))
end


function TestAccessSystem:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


return TestAccessSystem