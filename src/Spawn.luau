--[=[
    @class Spawn
    Works like task.spawn for activities that may yield the compilation process.
]=]
local m = {__type = script.Name;};
m.__index = m;
local Types = require(script.Parent.Types)
local tins,tf,tc,tr = table.insert,table.find,table.clear,table.remove

--[=[
    @method Destroy
    @within Spawn
    Deletes the task if not already deleted.
]=]
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
--[=[
    @method Perform
    @within Spawn
    This method performs the tasks then self destructs right after.
]=]
function m:Perform(Entity,Index,Compile,Thread)
    local createdtask; createdtask = task.spawn(function()
        local ret = self.func(Entity)
        if ret ~= nil then
            if typeof(Index) == "number" then
                Compile(Entity,(typeof(ret) == "table" and ret.__type == nil and ret) or {ret},Thread)
            else
                Entity[Index] = ret;
            end
        end

        if Thread ~= nil then
            if Thread["Remove"] ~= nil then
                Thread:Remove(createdtask)
            else
                local f = tf(Thread,createdtask)
                if f ~= nil then
                    tr(Thread,f)
                end;
            end
            createdtask = nil;
        end
    end)
    if Thread ~= nil then
        if Thread["Add"] ~= nil then
            Thread:Add(createdtask)
        else
            tins(Thread,createdtask)
        end
    end
    self:Destroy();
end
--[=[
    @method Spawn
    @within Thread
    @param func function
    @param Thread Thread?
    Creates a new task
]=]
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
