local m = {__type = script.Name;};
m.__index = m;
local Types = require(script.Parent.Types)
local tins,tf,tc,tr = table.insert,table.find,table.clear,table.remove

function m:Destroy()
    if self.Thread ~= nil then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local f= tf(self.Thread,self)
            if f ~= nil then
                tr(self,f)
            end
        end
    end
    tc(self)
    setmetatable(self,nil)
end
function m:Perform(Entity,Index,Compile,Thread)
    task.spawn(function()
        local ret = self.func(Thread,Entity)
        if ret ~= nil then
            if typeof(ret) == "table" then
                if ret.__type ~= nil then
                    ret = {
                        Index = ret;
                    }
                    Compile(Entity,ret,Thread)
                end
            else
                Entity[Index] = ret;
            end
        end
    end)
    self:Destroy();
end
return function(func: () -> (), Thread: Types.Thread)
    local new = {
        func = func;
        Thread = Thread;
    }
    setmetatable(new,m)
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new;
end
