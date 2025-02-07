local Types = require(script.Parent.Types)
local tof,tins,tf,tr,tc = typeof,table.insert,table.find,table.remove,table.clear
local Signal = require(script.Parent.Packages.Signal);

local mt = {};
mt.__index = mt;

function mt:Destroy()
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
    if self.Changed ~= nil then
        self.Changed:Destroy()
        self.Changed = nil;
    end
    if self.Connection ~= nil then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    setmetatable(self,nil)
    tc(self)
end
function mt:SetTime(New: number)
    if New == nil or tof(New) ~= "number" then return end;
    self.Time = New;
end
function mt:Get()
    if self.Value == nil or self.Value.Initial == nil then return end;
    return self.Value:Get()
end
return function(Value: Types.Value, Time: number, Thread: Types.Thread)
    if Value == nil or Time == nil then warn(`Value or Time parameter are missing - {debug.traceback()}`); return end;
    if tof(Value) ~= "table" and typeof(Time) ~= "number" then warn(`Parameters must be of the format: Value: Value, Time: number - {debug.traceback()}`); return end;
    local new = {
        __type = script.Name;
        Initial = Value.Initial;
        Thread = Thread;
        Connection = nil;
        Value = Value;
        Time = Time;
        IsActive = true;
        Changed = Signal.new();
    }
    setmetatable(new,mt);
    new.Connection = Value.Changed:Connect(function(...)
        if not new.IsActive then return end
        task.wait(new.Time)
        if not new.IsActive then return end
        new.Changed:Fire(...)
    end)
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new;
end
