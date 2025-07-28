local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
--[=[
    @method AttributeChanged
    @within Thread
    @param Attribute string
    @param Thread any?
    @return AttributeChanged
    Attribute changed listener
]=]
local typetxt = script.Name;
return function (Method: string,Index: string, Thread: Types.Thread?)
    if Method == nil or Index == nil then return end;
    local d = {Method = Method,Index = Index,Thread = Thread, __type = typetxt};
    if Thread ~= nil then
        Utility.AddToThread(Thread,d)
    end;
    return d;
end