local Types = require(script.Parent.Types)
--[=[
    @method MethodSignaled
    @within Thread
    @param Method string
    @param Index string
    @param RunOnInitialization boolean?
    @param Thread Thread?
    Listener for methods, example: 'GetPropertyChangedSignal', 'GetAttributeChangedSignal', etc.
]=]
local typetxt = script.Name;
return function (Method: string,Index: string, RunOnInitialization: boolean?, Thread: Types.Thread?)
    if Method == nil or Index == nil then return end;
    return {Method = Method,Index = Index,RunOnInitialization = RunOnInitialization,Thread = Thread, __type = typetxt};
end