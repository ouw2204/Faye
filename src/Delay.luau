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
    if not (New == nil or tof(New) == "number") then return end;
    self.Time = New;
end
function mt:Get()
    if self.Value == nil then return end;
    return self.Value:Get()
end
function mt:Sensitive()
    self.IsSensitive = true;
    return self;
end
function mt:ResetTime()
    self.Time = self.DefaultTime
end
local Id = 0;
local curentUsageId = 0;
local scriptName = script.Name;
function mt.__tostring()
    return scriptName;
end
return function(Value: Types.Value, Time: number, Thread: Types.Thread)
    if Value == nil or Time == nil then warn(`Value or Time parameter are missing - {debug.traceback()}`); return end;
    if tof(Value) ~= "table" and typeof(Time) ~= "number" then warn(`Parameters must be of the format: Value: Value, Time: number - {debug.traceback()}`); return end;
    Id += 1;
    local new = {
        __type = script.Name;
        Initial = Value.Initial;
        Thread = Thread;
        Connection = nil;
        Value = Value;
        DefaultTime = Time;
        Time = Time;
        Id = "Delay-"..Id;
        IsActive = true;
        Changed = Signal.new();
    }
    setmetatable(new,mt);
    new.Connection = Value.Changed:Connect(function(...)
        curentUsageId +=1;
        new.currentId = curentUsageId;
        if new.Time ~= nil then
            if not new.IsActive then return end
            task.wait(new.Time)
            if not new.IsActive then return end
        end;
        if new.IsSensitive == nil or new.currentId == curentUsageId then
            new.Changed:Fire(...)
        end
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
