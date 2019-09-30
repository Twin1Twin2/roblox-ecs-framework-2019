--- OwnerComponent
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local ComponentDescription = ECSFramework.ComponentDescription


local OwnerComponent = ComponentDescription.new("OwnerComponent")

OwnerComponent.Fields = {
    "Owner"
}

OwnerComponent.Defaults = {
    Owner = nil;
}


return OwnerComponent