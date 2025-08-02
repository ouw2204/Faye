local Utility = require(script.Parent.Misc.Utility)
local Types = script.Parent.Types;

local firsttxt = "is_first123"
return function (func: (Grab: (Value: Instance | Types.Value) -> any) -> (),Thread: Types.Thread?)
    
    local Log;
    local Connections;
    local Delete;
    local Trigger;
    local Grab = function(Value: any)
        if Value == nil then return end;
        if Log == nil then Log = {}; Connections = {} end;
        if Value.ClassName ~= nil then
            if Log[Value] == nil then
                Log[Value] = true;
                Utility.tins(Connections,Value.Changed:Connect(Trigger))
            end
            return Value.Value;
        else
            if Log[Value.Id] == nil then
                Log[Value.Id] = true;
                Utility.tins(Connections,Value.Changed:Connect(Trigger,Connections))
            end
    
            return Value:Get();
        end
    end
    Trigger = function(ft: string)
        func(Grab)
        if ft == firsttxt and Connections ==nil then
            Delete()
        end
    end
    Delete = function()
        if Thread ~= nil then
            Utility.RemoveFromThread(Thread,Delete)
        end;
        if Log ~= nil then
            Utility.tc(Log);
            Log = nil;
        end;
        if Connections ~= nil then
            Utility.ClearAllConnections(Connections)
            Connections = nil;
        end
        Grab = nil;
        Trigger = nil;
        Delete = nil;
    end
    Trigger(firsttxt)
    if Thread ~= nil then
        Utility.AddToThread(Thread,Delete)
    else
        return Delete()
    end
end