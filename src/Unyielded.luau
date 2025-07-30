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
local threadclean = task.cancel
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
    if self.createdtask ~= nil then
        threadclean(self.createdtask)
        self.createdtask = nil;
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
    local func = function()
        local ret = self.func(Entity)
        if ret ~= nil then
            if typeof(Index) == "number" then
                Compile(Entity,(typeof(ret) == "table" and ret.__type == nil and ret) or {ret},Thread)
            else
                Entity[Index] = ret;
            end
        end
        self.createdtask = nil;
        self:Destroy();
    end
    if self.Time ~= nil and self.Time >0 then
        self.createdtask = task.delay(self.Time,func)
    else
        self.createdtask = task.spawn(func)
    end
end
--[=[
    @method Spawn
    @within Thread
    @param func function
    @param Thread Thread?
    @param Time number?
    Creates a new task
]=]
return function(func: () -> (), Thread: Types.Thread,Time: number?)
    local new = {
        func = func;
        Thread = Thread;
        Time = Time;
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
