local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)

return function (Instance: Types.FayeInstance,Index, State: Types.Value,Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> ())
    local Thread = Instance.InnerThread or Instance.Thread;
    if State.IsState and (Thread == nil or Thread["Extend"] == nil) then
        warn("State only works if the entity has a thread and the thread has an :Extend method")
        return
    end
    local Log;
    local Connections;
    local Grab,Trigger;
    --| Trigger
    local InnerThread;
    Trigger = function()
        if InnerThread ~= nil then
            InnerThread:Destroy();
            InnerThread = nil;
        end
        if State.IsState then
            InnerThread = Thread:Extend();
        end
        local res1,res2 = if State.IsState then State.Func(Grab,InnerThread,Instance.Instance) else State.Func(Grab,Instance.Instance)
        if res1 ~= nil then
            local Entity = {Instance = Instance.Instance,Thread = InnerThread};
            if Index ~= nil and Utility.tof(Index) ~= Utility.numbertxt then
                Compile(Entity,{[Index] = res1},InnerThread)
            else
                if res2 ~= nil then
                    Compile(Entity,{[res1] = res2},InnerThread)
                else
                    Compile(Entity,res1,InnerThread)
                end
            end
            Entity = nil;
        else
            if InnerThread ~= nil then
                InnerThread:Destroy();
                InnerThread = nil;
            end
        end

    end
    --|> Trigger
    --| grab
    Grab = function(Value: any, Property: string?,InstanceMethod: string?)
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
    Trigger()
    --| delete
    if Thread == nil then return end;
    local function Delete()
        Utility.RemoveFromThread(Thread,Delete)
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
        print("Delete")
    end
    Utility.AddToThread(Thread,Delete)
end