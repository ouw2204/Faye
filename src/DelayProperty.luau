local Types = require(script.Parent.FayeTypes)
local Utility = require(script.Parent.Misc.FayeUtility)

--[=[
    @method DelayProperty
    @within Thread
    @param Props Types.Properties
    @param Time number
    @param From any
    @return DelayProperty
    Creates a new delay object that will compile the given properties after [Time] time.
]=]
local typetxt = script.Name;
return function(Props: Types.Properties | any,Time: number,From: any,Thread: Types.Thread?)
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
