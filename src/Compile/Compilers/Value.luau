local tf, tins, tr, tof, tc = table.find, table.insert, table.remove, typeof, table.clear
local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)


return function (Entity: Types.Instance, Index: any, Value: Types.Value)
    local Instance = Entity.Instance or Entity

    local connectionslength = 0;
    local connections = {};

    local mainFunc; mainFunc = function(Gotten: any,Position: number?)
        local gottenIsTable = tof(Gotten) == "table"
        Position = Position or 1;
        if gottenIsTable and Gotten.__type ~= nil and ValueClasses[Gotten.__type] then
            connectionslength = Position;
            connections[Position] = Gotten.Changed:Connect(function(new)
                if connectionslength > Position then
                    for i = connectionslength,Position+1,-1 do
                        connections[i]:Disconnect();
                        connections[i] = nil;
                    end
                end
                connectionslength = Position;
                mainFunc(new,Position + 1)
            end)
            mainFunc(Gotten:Get(),Position + 1)
        else
             if Entity ~= nil and Instance ~= nil then
                if gottenIsTable then
                    Gotten = Gotten.Instance or Gotten
                end
                local tofIndex = tof(Instance[Index])
                local tofNew = tof(Gotten)
                if tofIndex == tofNew or (tofIndex == "nil" and tofNew ~= nil) or ((tofIndex == "number" or tofIndex == "string") and (tofNew == "number" or tofNew == "string")) then
                    Instance[Index] = Gotten
                end
                tofIndex = nil
                tofNew = nil
            end
        end
    end
    mainFunc(Value)
    local Thread = Entity.Innerthread or Entity.Thread
    local clean; clean = function()
        if Thread ~= nil then
            Utility.RemoveFromThread(Thread,clean)
        end;
        Value.__cleanFunction = nil;
        Thread = nil;
        Utility.ClearAllConnections(connections,connectionslength)
        tc(connections)
        connections = nil;
        --print("clean ",script.Name)
    end
    Value.__cleanFunction = clean
    if Thread ~= nil then
        Utility.AddToThread(Thread,clean)
    end
end