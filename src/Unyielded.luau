local Utility = require(script.Parent.Misc.Utility)
local Types = require(script.Parent.Types)

local typetxt = script.Name;
return function (func: () -> (),DelayTime: number?,Thread: Types.Thread)
    local new = {func = func, DelayTime = DelayTime,__type = typetxt};
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end