local ValueBase = require(script.Parent.Misc.ValueBase);
local Signal = require(script.Parent.Packages.SimpleSignal);
local Types = require(script.Parent.FayeTypes)
local Utility = require(script.Parent.Misc.FayeUtility)
local typeTxt = "InstancePropertySync";

local Counter = 0;
local attextension = "_Attribute"
--[=[
    @method InstanceAttributeSync
    @within Thread
    @param Entity Instance
    @param Property string
    @return InstanceAttributeSync
    Creates a Value object that syncs with a specific attribute of an Instance.
]=]
return function (Entity: Instance, Property: string, Thread: Types.Thread?)
    local new = {Changed = Signal.new(),Id = typeTxt..Counter..attextension,IsProperty = true,Thread = Thread,__type = typeTxt,IsAttribute = true};
    setmetatable(new,ValueBase)
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    new:ReCalibrate(Entity,Property)
    Counter += 1;
    return new;
end