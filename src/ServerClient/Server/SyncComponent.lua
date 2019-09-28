--- SyncComponent_Server
--
-- AccessData = {
--     ["Component1"] = {
--         Type = "OWNER_WRITE";    -- Owner has write access; Everyone else has read access;
--         Owner = Player;
--     };
--     ["Component2"] = {
--         Type = "SELECT_READ";
--         Players = {};
--     };
-- };
-- ComponentsUpdated = {
--     "Component1",
--     "Component2"
-- };

local ComponentDescription = require(script.Parent.Parent.Parent.ECSComponentDescription)


local SyncComponent_Server = ComponentDescription.new("SyncComponent")

SyncComponent_Server.Fields = {
    "AccessData",
    "PreviousAccessData"
}

SyncComponent_Server.Defaults = {
    AccessData = {};
    PreviousAccessData = {};
}


return SyncComponent_Server