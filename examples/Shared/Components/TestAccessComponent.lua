--- TestAccessComponent
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local ComponentDescription = ECSFramework.ComponentDescription


local TestAccessComponent = ComponentDescription.new("TestAccessComponent")

TestAccessComponent.Fields = {

}

TestAccessComponent.Defaults = {

}


return TestAccessComponent