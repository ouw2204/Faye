local Signal = script.Parent.Signal
local Types = require(script.Parent.Types)
local typetxt = 'Signal';
local Utility = require(script.Parent.Misc.FayeUtility)
local Runner = require(Signal.Runner)
local mt = require(Signal.SignalMetatable)

--[=[
    @method SignalState
    @within Thread
    @param Connections RBXScriptSignal | {RBXScriptSignal}
    @param func (...any) -> ()?
    @return SignalState
    Creates a reactive signal that runs the provided function whenever any of the provided connections fire, this one deletes the old components before loading the new returned returned ones.
]=]

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