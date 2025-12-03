--[=[
    @class DelayValue
    A class that represents a value with a delay and threading.
]=]
local Types = require(script.Parent.Types)
local Signal = require(script.Parent.Packages.SimpleSignal);
local Utility = require(script.Parent.Misc.FayeUtility)
local typetxt = script.Name;
local mt = {
    __type = typetxt;
};
mt.__index = mt;

--[=[
    @method Destroy
    @within DelayValue
    Destroys the delay value object and cleans up its resources.
]=]
function mt:Destroy()
    local thread = self.Thread
    if thread ~= nil then
        if thread["Remove"] then
            thread:Remove(self)
        else
            local pos = Utility.tf(thread, self)
            if pos ~= nil then
                Utility.tr(thread, pos)
            end
        end
        self.Thread = nil
    end
    if self.Changed ~= nil then
        self.Changed:Destroy()
        self.Changed = nil;
    end
    if self.Connection ~= nil and self.Connection["Disconnect"] ~= nil then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if self.Custom ~= nil then
        Utility.tc(self.Custom)
        self.Custom = nil;
    end
    setmetatable(self,nil)
    self.Initial = nil;
    self.Value = nil;
    self.DefaultTime = nil;
    self.Time = nil;
    self.Id = nil;
    self.IsActive = nil;
    Utility.tc(self)
end

--[=[
    @method SetTime
    @within DelayValue
    @param New number
    Sets the delay time.
]=]
function mt:SetTime(New: number)
    if not (New == nil or Utility.tof(New) == "number") then return self end;
    self.Time = New;
    return self;
end
--[=[
    @method For
    @within Delay
    @param Value any
    @param Time number
    Sets a custom wait time for a value
]=]
function mt:For(Value: any,Time: number?)
    if self.Custom == nil then
        self.Custom = {};
    end
    self.Custom[Value] = Time;
    self.IsSensitive = true
    return self;
end
--[=[
    @method Get
    @within DelayValue
    @return any
    Returns the current value.
]=]
function mt:Get()
    if self.Value == nil then return end;
    return self.Value:Get()
end

--[=[
    @method Refresh
    @within DelayValue
    Triggers the changed signal.
]=]
function mt:Refresh()
    if self.Value == nil then return end;
    if self.SignalEnabled == nil or self.SignalEnabled == true then
        self.Value.Changed:Fire(self:Get())
    end
end
--[=[
    @method SetSignalEnabled
    @within DelayValue
    @param Enabled boolean
]=]
function mt:SetSignalEnabled(Enabled: boolean)
    self.SignalEnabled = Enabled;
end
--[=[
    @method Sensitive
    @within DelayValue
    Marks the delay value as sensitive, meaning it won't send a signal if another update is in queue.
    @return DelayValue
]=]
function mt:Sensitive()
    self.IsSensitive = true;
    return self;
end

--[=[
    @method ResetTime
    @within DelayValue
    Resets the delay time to the default time.
]=]
function mt:ResetTime()
    self.Time = self.DefaultTime
end

local Id = 0;
local scriptName = script.Name;

function mt.__tostring()
    return scriptName;
end

--[=[
    @method DelayValue
    @within Thread
    @param Value Types.Value
    @param Time number
    @return DelayValue
    Creates a new delay value object.
]=]
return function(Value: Types.Value, Time: number, Thread: Types.Thread)
    if Value == nil then warn(`Value or Time parameter are missing - {debug.traceback()}`); return end;
    if Utility.tof(Value) ~= "table" then warn(`Parameters must be of the format: Value: Value, Time: number - {debug.traceback()}`); return end;
    Id += 1;
    local new = {
        Initial = Value.Initial;
        Thread = Thread;
        Connection = nil;
        Value = Value;
        curentUsageId = 0;
        DefaultTime = Time;
        Time = Time;
        Id =typetxt .. Id;
        IsActive = true;
        Changed = Signal.new();
    }
    setmetatable(new,mt);
    new.Connection = Value.Changed:Connect(function(newValue: any)
        if new.SignalEnabled == false then return end;
        new.curentUsageId +=1;
        local currentId = new.curentUsageId;
        local eqTime = new.Time;
        if newValue ~= nil and new.Custom ~= nil and new.Custom[newValue] ~= nil then
            eqTime = new.Custom[newValue];
        end
        if eqTime ~= nil and eqTime ~= 0 then
            if not new.IsActive then return end
            task.wait(eqTime)
            if not new.IsActive then return end
        end;
        if new.IsSensitive == nil or currentId == new.curentUsageId then
            new.Changed:Fire(newValue)
        end
    end)
    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end
