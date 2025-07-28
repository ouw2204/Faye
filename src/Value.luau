local ValueBase = require(script.Parent.Misc.ValueBase);
local Signal = require(script.Parent.Packages.Signal);
local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
local typeTxt = script.Name;
return function (Initial: any,Thread: Types.Thread?)
    local new = {__type = typeTxt,Changed = Signal.new(),Initial = Initial, ValueType = Utility.tof(Initial),Thread = Thread};
    setmetatable(new,ValueBase);
    if Thread ~= nil then
        Utility.AddToThread(Thread, new);
    end
    return new;
end