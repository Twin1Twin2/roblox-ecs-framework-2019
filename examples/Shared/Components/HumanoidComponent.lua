--- HumanoidComponent
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local ComponentDescription = ECSFramework.ComponentDescription


local HumanoidComponent = ComponentDescription.new("HumanoidComponent")

HumanoidComponent.Fields = {
    "Humanoid"
}

HumanoidComponent.Defaults = {

}


return HumanoidComponent