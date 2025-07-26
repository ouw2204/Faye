local Types = require(script.Parent.Types)
local typetxt = script.Name;
return function(Function: (Grab: any,InnerThread: Types.Thread,Entity: Instance?) -> any,Thread: Types.Thread)
    local new = {Func = Function, __type = typetxt,IsState = true};
    return new;
end