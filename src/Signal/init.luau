local Types = require(script.Parent.Types)
local typetxt = script.Name;
local Utility = require(script.Parent.Misc.Utility)
local Runner = require(script.Runner)
local mt = require(script.SignalMetatable)

return function(Connections: RBXScriptSignal | {RBXScriptSignal},func: (...any) -> ()?, Thread: Types.Thread?)
    if func == nil then return end;
    local new = {__type = typetxt};
    Runner(new,Connections,func)
    setmetatable(new,mt)
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end