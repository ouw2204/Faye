local Utility = require(script.Parent.Misc.FayeUtility)
local Types = require(script.Parent.Types)

local typetxt = script.Name;

--[=[
    @method YieldSafe
    @within Thread
    @param func () -> ()
    @param DelayTime number?
    @return YieldSafe
    Creates a YieldSafe object that can be used to run functions with yields safely.
]=]

return function (func: () -> (),DelayTime: number?,Thread: Types.Thread)
    local new = {func = func, DelayTime = DelayTime,__type = typetxt};
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end