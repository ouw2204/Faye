local Types = require(script.Parent.Misc.OtherTypes)
local tof,tins,tf,tr,tc = typeof,table.insert,table.find,table.remove,table.clear
local Signal = require(script.Parent.Packages.Signal);

return function(Value: Types.Value, Time: number, Thread: Types.ThreadType)
    if Value == nil or Time == nil then warn(`Value or Time parameter are missing - {debug.traceback()}`); return end;
    if tof(Value) ~= "table" and typeof(Time) ~= "number" then warn(`Parameters must be of the format: Value: Value, Time: number - {debug.traceback()}`); return end;
    local new = {
        __type = script.Name;
        Initial = Value.Initial;
        Thread = Thread;
        Connection = nil;
        Time = Time;
        IsActive = true;
        Changed = Signal.new();
    }
    function new:SetTime(New: number)
        if New == nil or tof(new) ~= "number" then return end;
        new.Time = New;
    end
    function new:Get()
        if Value == nil or Value.Initial == nil then return end;
        return Value:Get()
    end
    new.Connection = Value.Changed:Connect(function(...)
        if not new.IsActive then return end
        task.wait(new.Time)
        if not new.IsActive then return end
        new.Changed:Fire(...)
    end)
    function new:Destroy()
        local thread = self.Thread
        if thread ~= nil then
            if thread["Remove"] then
                thread:Remove(self)
            else
                local pos = tf(thread, self)
                if pos ~= nil then
                    tr(thread, pos)
                end
            end
            self.Thread = nil
        end
        
        self.Changed:Destroy()
        
        if self.Connection ~= nil then
            self.Connection:Disconnect()
            self.Connection = nil
        end
    
        tc(self)
    end
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new;
end
