local Utility = require(script.Parent.Misc.FayeUtility)
local Types = require(script.Parent.Types)

local typetxt = script.Name;

--[=[
    @method YieldSafe
    @within Thread
    @param func () -> ()
    @param DelayTime number?
    @param Thread Thread?
    @return YieldSafe
]=]

return function (func: () -> (),DelayTime: number?,Thread: Types.Thread)
    local new = {func = func, DelayTime = DelayTime,__type = typetxt};
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end