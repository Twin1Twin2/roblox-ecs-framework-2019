
local IsType = {}

IsType.ComponentAccessType = function(self)
    return type(self) == "table" and self._IsComponentAccessType == true
end


return IsType