local ValueBase = require(script.Parent.Misc.ValueBase);
local Signal = require(script.Parent.Packages.SimpleSignal);
local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
local typeTxt = "InstancePropertySync";

local Counter = 0;
local attextension = "_Attribute"
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