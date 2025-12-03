local Types = require(script.Parent.Types)
local typetxt = script.Name;
--[=[
    @method SpecialThread
    @within Thread
    @param func (Thread: Types.Thread, Entity: Instance) -> ()
    @param Params (Types.SpecialThreadParams | number)?
    @return SpecialThread
    Creates a special thread object that can be used in Faye's threading system with custom settings.
]=]
return function (func: (Thread: Types.Thread, Entity: Instance) -> (),Params: (Types.SpecialThreadParams | number)? )
    if func == nil then return end;
    return {__type = typetxt,func = func,Params = Params}
end