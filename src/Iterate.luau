local Types = require(script.Parent.Types)
local typetxt = script.Name;
local Utility = require(script.Parent.Misc.Utility)
return function(Tab: any,Func: (Index: any,Value: any,InnerThread: Types.Thread?,Entity: Instance?) -> (),Thread: Types.Thread)
    local Iterate = {
        Tab = Tab,
        Function = Func,
        Thread = Thread,
        __type = typetxt,
    }
    if Thread ~= nil then
        Utility.AddToThread(Thread, Iterate)
    end
    return Iterate;
end