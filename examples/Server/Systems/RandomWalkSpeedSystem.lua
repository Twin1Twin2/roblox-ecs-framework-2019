--- RandomWalkSpeedSystem
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local System = ECSFramework.System


local RandomWalkSpeedSystem = {
    ClassName = "RandomWalkSpeedSystem";
}

RandomWalkSpeedSystem.__index = RandomWalkSpeedSystem
setmetatable(RandomWalkSpeedSystem, System)


function RandomWalkSpeedSystem.new()
    local self = setmetatable(System.new(), RandomWalkSpeedSystem)

    self.IsActive = false

    self.ComponentRequirement
        :All("HumanoidComponent")


    return self
end


function RandomWalkSpeedSystem:AddedToWorld(world)
    self.IsActive = true

    spawn(function()
        while self.IsActive == true do
            self:DoUpdate()
			wait(2)
        end
    end)
end


function RandomWalkSpeedSystem:RemovedFromWorld(world)
    self.IsActive = false
end


function RandomWalkSpeedSystem:UpdateEntity(entity)
    local humanoidComponent = entity:GetComponent("HumanoidComponent")
    local humanoid = humanoidComponent.Humanoid

    if math.random(1, 10) == 1 then
        humanoid.WalkSpeed = 16
    else
        -- entity:addComponent("WalkSpeed", {   -- taken from Rocs
        --     speed = math.random(2, 40);
        --     secret = "very secret";
        -- })

        local speed = math.random(2, 40)
        humanoid.WalkSpeed = speed
    end
end


function RandomWalkSpeedSystem:Update(entities)
    for _, entity in pairs(entities) do
        self:UpdateEntity(entity)
    end
end


return RandomWalkSpeedSystem