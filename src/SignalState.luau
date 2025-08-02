local Signal = script.Parent.Signal
local Types = require(script.Parent.Types)
local typetxt = 'Signal';
local Utility = require(script.Parent.Misc.Utility)
local Runner = require(Signal.Runner)
local mt = require(Signal.SignalMetatable)

return function(Connections: RBXScriptSignal | {RBXScriptSignal},func: (...any) -> ()?, Thread: Types.Thread?)
    if func == nil then return end;
    local new = {__type = typetxt,IsState = true};
    Runner(new,Connections,func)
    setmetatable(new,mt)
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end