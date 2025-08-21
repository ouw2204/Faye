local Utility = require(script.Parent.Parent.Misc.Utility)
local mt = {};
mt.__index = mt;

function mt:Destroy()
    if self.Connections ~= nil then
        Utility.ClearAllConnections(self.Connections,self.Connections.Count)
    end
   Utility.tc(self);
   setmetatable(self,nil);
end
function mt:Connect(Connection: any)
    if Connection == nil then return end;
    if self.Connections == nil then
        self.Connections = {Count = 0}
    end
    self.Connections[self.Connections.Count + 1] = Connection:Connect(self.receiverFunc,self.Connections)
    self.Connections.Count += 1;
    return self;
end
function mt:Call(...)
    if self.Entries == nil then
        task.defer(self.receiverFunc,...)
    else
        self.receiverFunc(...)
    end
    return self;
end

local typetxt = script.Parent.Name;
mt.__tostring = function()
    return typetxt;
end

return mt;