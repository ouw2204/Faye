local Signal = require(script.Parent.Packages.Signal)


--[=[
    @method signal
    @within Thread
    @param Thread table
    @return Signal
    Creates a new signal object.
]=]
return function(Thread)
    local Sig = Signal.new();
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(Sig)
        else
            table.insert(Thread,Sig)
        end
    end
    return Sig;
end
