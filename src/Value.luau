local ValueBase = require(script.Parent.Misc.ValueBase);
local Signal = require(script.Parent.Packages.SimpleSignal);
local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
local typeTxt = script.Name;
local Counter = 0;
return function (Initial: any,Thread: Types.Thread?)
    local new = {__type = typeTxt,Id = typeTxt..Counter,Changed = Signal.new(),Initial = Initial, ValueType = Utility.tof(Initial),Thread = Thread,Value = Initial};
    setmetatable(new,ValueBase);
    if Thread ~= nil then
        Utility.AddToThread(Thread, new);
    end
    Counter += 1;
    return new;
end