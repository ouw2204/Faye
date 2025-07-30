local Utility = require(script.Parent.Parent.Misc.Utility)
connecttxt = "Connect"
return function (new: {any: any}, Connections: RBXScriptSignal | {RBXScriptSignal}, func: (...any) -> () )
    new.receiverFunc = function(...)
        if new.Entries ~= nil then
            for i = 1,new.Entries.Count do
                local Eq = new.Entries[i]
                print(Eq," is entry")
            end
        else
            func(...)
        end
    end
    if Connections ~= nil then
        if new.Connections == nil then
            new.Connections = {Count = 0}
        end
        if Utility.tof(Connections) == Utility.tabletxt and Connections[connecttxt] == nil then
            for _,v: RBXScriptSignal in ipairs(Connections) do
                new.Connections[new.Connections.Count + 1] = v:Connect(new.receiverFunc,new.Connections)
                new.Connections.Count += 1;
            end
        else
            new.Connections[new.Connections.Count + 1] = Connections:Connect(new.receiverFunc,new.Connections)
            new.Connections.Count += 1;
        end
    end
end