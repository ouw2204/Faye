local Types = require(script.Parent.Types)
local typetxt = "Iterate";

return function(Tab: any,Func: (Index: any,Value: any,InnerThread: Types.Thread?,Entity: Instance?) -> (),Thread: Types.Thread)
    local Iterate = {
        Tab = Tab,
        Function = Func,
        __type = typetxt,
        Advanced = true;
    }
    
    return Iterate;
end