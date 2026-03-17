local ValueBase = require(script.Parent.Misc.ValueBase);
local Signal = require(script.Parent.Parent.simplesignal);
local Types = require(script.Parent.FayeTypes)
local Utility = require(script.Parent.Misc.FayeUtility)
local typeTxt = script.Name;
local Counter = 0;
--[=[
    @method Value
    @within Thread
    @param Initial any
    @return Value
    Creates a Value object that can be used in Faye's reactive system.
]=]
return function (Initial: any,Thread: Types.Thread?)
    local new = {__type = typeTxt,Id = typeTxt..Counter,Changed = Signal.new(),Initial = Initial, ValueType = Utility.tof(Initial),Thread = Thread,Value = Initial};

    --| important |--
    new.ValueTypeIsTable = new.ValueType == Utility.tabletxt
    
    setmetatable(new,ValueBase);
    if Thread ~= nil then
        Utility.AddToThread(Thread, new);
    end
    Counter += 1;
    return new;
end