local m = {};
m.__index = m;
local Utility = require(script.Parent.Utility);
local Types = require(script.Parent.Parent.Types);
local Actions = require(script.Parent.TypeActions)

function m:Destroy()
    if self.Thread ~= nil then
        Utility.RemoveFromThread(self.Thread,self)
        self.Thread = nil;
    end
    if self.Signal ~= nil then
        self.Signal:Destroy();
        print("destroy signal")
        self.Signal = nil;
    end
    Utility.tc(self)
    setmetatable(self,nil)
end

return m;