local ValueBase = require(script.Parent.Misc.ValueBase);
local Signal = require(script.Parent.Parent.simplesignal);
local Types = require(script.Parent.FayeTypes)
local Utility = require(script.Parent.Misc.FayeUtility)
local typeTxt = script.Name;

local Counter = 0;
--[=[
    @method InstancePropertySync
    @within Thread
    @param Entity Instance
    @param Property string
    @return InstancePropertySync
    Creates a Value object that syncs with a specific property of an Instance.
]=]
return function (Entity: Instance, Property: string, Thread: Types.Thread?)
    local new = {Changed = Signal.new(),Id = typeTxt..Counter,IsProperty = true,Thread = Thread,__type = typeTxt};
    setmetatable(new,ValueBase)
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    new:ReCalibrate(Entity,Property)
    Counter += 1;
    return new;
end