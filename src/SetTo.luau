--[=[
    @method SetTo
    @within Thread
    @param Value any
    @return SetTo
    Wraps a value into a SetTo value object that can be used in props tables.
]=]
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Utility = require(script.Parent.Misc.FayeUtility)
local types = require(script.Parent.FayeTypes)
local typetxt = script.Name;
return function(Value: any,Thread: types.Thread?) : any
    if Value == nil or Utility.tof(Value) ~= "table" or Value.__type == nil or ValueClasses[Value.__type] == nil then warn(`Pass a valid value object - {debug.traceback()}`); return end;
    local new = {
        Value = Value;
        __type = typetxt;
    };
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end