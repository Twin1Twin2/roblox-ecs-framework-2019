--- OwnedInputComponent
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ECSFramework = require(ReplicatedStorage:WaitForChild("ECSFramework"))
local ComponentDescription = ECSFramework.ComponentDescription


local OwnedInputComponent = ComponentDescription.new("OwnedInputComponent")

OwnedInputComponent.Fields = {
    "Input",
}

OwnedInputComponent.Defaults = {
    Input = false;
}


return OwnedInputComponent