--- SyncComponent_Client
--
-- AccessData = {
--     ["Component1"] = READ_ONLY;
--     ["Component2"] = READ_WRITE;
--     ["Component3"] = NONE;
-- }

local ComponentDescription = require(script.Parent.Parent.Parent.ECSComponentDescription)


local SyncComponent_Client = ComponentDescription.new("SyncComponent")

SyncComponent_Client.Fields = {
    "AccessData"
}

SyncComponent_Client.Defaults = {
    AccessData = {};
}


return SyncComponent_Client