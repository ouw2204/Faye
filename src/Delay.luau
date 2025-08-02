local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
--[=[
    @class Delay
    A class that represents a delay with properties and threading.
]=]


--[=[
    @method Delay
    @within Thread
    @param Time number
    @param Props Types.Properties
    @param Thread Types.Thread
    @return Delay
    Creates a new delay object.
]=]
local typetxt = script.Name;
return function(Props: Types.Properties,Time: number,From: any,Thread: Types.Thread?)
    if Time == nil or Props == nil then warn(`Time or properties is missing - {debug.traceback()}`); return end;
    local new = {
        Time = Time;
        ToCompile = Props;
        Init = From;
        __type = typetxt
    };

    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end
