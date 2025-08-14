local Types = require(script.Parent.Types)
local typetxt = script.Name;
return function (func: (Thread: Types.Thread, Entity: Instance) -> (),Params: (Types.SpecialThreadParams | number)? )
    if func == nil then return end;
    return {__type = typetxt,func = func,Params = Params}
end