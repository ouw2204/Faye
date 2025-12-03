local Types = require(script.Parent.Types)
local typetxt = "State";
--[=[
    @method Do
    @within Thread
    @param func (Grab: any, InnerThread: Thread, Entity: Instance?) ->
    @return Do
    Creates a Do object that can be used in Faye's threading system to execute functions.
]=]
return function(Function: (Grab: any,InnerThread: Types.Thread,Entity: Instance?) -> any,Thread: Types.Thread)
    local new = {Func = Function, __type = typetxt};
    return new;
end