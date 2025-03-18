--[=[
    @class Iterate
    A class that handles iteration over tables.
]=]

local Types = require(script.Parent.Types)
local tins = table.insert
local tf,tr = table.find,table.remove
local tc = table.clear
local mt = {
    __type = script.Name;
}
mt.__index = mt;

--[=[
    @method Destroy
    @within Iterate
    Destroys the object and cleans up resources.
]=]
function mt:Destroy()
    if self.Thread ~= nil then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local f = tf(self.Thread,self)
            if f ~= nil then
                tr(self.Thread,f)
            end
        end
    end
    self.Tab = nil;
    self.Function = nil;
    tc(self)
    setmetatable(self,nil);
end

--[=[
    @method Get
    @within Iterate
    @return table
    Returns a new table with the results of the iteration.
]=]
function mt:Get()
    local New = {}
    for i,v in pairs(self.Tab) do
        local Index,Value = self.Function(i,v)
        if Value == nil then
            tins(New,Index)
        else
            self[Index] = Value;
        end
    end
    return New;
end
local scriptName = script.Name;
function mt.__tostring()
    return scriptName;
end

--[=[
    @function Iterate
    @within Iterate
    @param Tab table
    @param Func function
    @param Thread any?
    @return Iterate
    Creates a new Iterate object that iterates over the given table.
]=]
return function(Tab: {any: any},Func: (Index: any,Value: any,InnerThread: Types.Thread?,Entity: Instance?) -> (),Thread: Types.Thread)
    if Tab == nil or Func == nil then return end;
    local new = {
        Function = Func;
        Tab = Tab;
        Thread = Thread;
    };
    setmetatable(new,mt)
    if Thread ~= nil then
        if Thread["Add"] ~= nil then
            Thread:Add(new)
        else
            tins(Thread,new);
        end
    end
    return new;
end
