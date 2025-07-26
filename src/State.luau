local Types = require(script.Parent.Types)
local typetxt = script.Name;
return function(Function: (Grab: any,InnerThread: Types.Thread,Entity: Instance?) -> any,IsState: boolean?,Thread: Types.Thread)
    local new = {Func = Function, __type = typetxt,IsState = IsState};
    return new;
end