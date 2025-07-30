local ValueBase = require(script.Parent.Misc.ValueBase);
local Signal = require(script.Parent.Packages.Signal);
local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
local typeTxt = script.Name;

local Counter = 0;
return function (Entity: Instance, Property: string,IsAttribute: boolean?, Thread: Types.Thread?)
    local new = {Changed = Signal.new(),Id = typeTxt..Counter,IsProperty = true,Thread = Thread,__type = typeTxt,IsAttribute = IsAttribute};
    setmetatable(new,ValueBase)
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    new:ReCalibrate(Entity,Property)
    Counter += 1;
    return new;
end