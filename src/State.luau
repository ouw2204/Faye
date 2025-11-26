local Types = require(script.Parent.Types)
local typetxt = script.Name;

--[=[
    @method State
    @within Thread
    @param func (Grab: any, InnerThread: Thread, Entity: Instance?) -> ()
    @return State
]=]

return function(Function: (Grab: any,InnerThread: Types.Thread,Entity: Instance?) -> any)
    local new = {Func = Function, __type = typetxt,IsState = true};
    return new;
end