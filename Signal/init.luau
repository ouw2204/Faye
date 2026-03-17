local Types = require(script.Parent.FayeTypes)
local typetxt = script.Name;
local Utility = require(script.Parent.Misc.FayeUtility)
local Runner = require(script.Runner)
local mt = require(script.SignalMetatable)
--[=[
    @method Signal
    @within Thread
    @param Connections RBXScriptSignal | {RBXScriptSignal} -- The signal or list of signals to connect to
    @param func (...any) -> ()? -- The function to execute when the signal is
    @return Signal
    Creates a signal object that listens to the specified connections and executes the provided function in a reactive manner.
]=]
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