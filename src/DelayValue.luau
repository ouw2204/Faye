--[=[
    @class DelayValue
    A class that represents a value with a delay and threading.
]=]
local Types = require(script.Parent.FayeTypes)
local Signal = require(script.Parent.Packages.SimpleSignal);
local Utility = require(script.Parent.Misc.FayeUtility)
local ValueBase = require(script.Parent.Misc.ValueBase)
local ValueClasses = require(script.Parent.Misc.ValueClasses)
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
    Utility.tc(self)
end
function mt:Add(Amount: any)
    if self.valueIsValue then
        self.Value:Add(Amount)
    else
        ValueBase.Add(self,Amount)
    end
end
function mt:Remove(Amount: any)
    if self.valueIsValue then
        self.Value:Remove(Amount)
    else
        ValueBase.Remove(self,Amount)
    end
end
function mt.__sub(self,value)
    if value == nil then return self end;
    self:Remove(value)
    return self;
end

function mt.__add(self,value)
    if value == nil then return self end;
    self:Add(value)
    return self;
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
    @within DelayValue
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
    if self.valueIsValue then
        return self.Value:Get()
    else
        return self.Value
    end
end

--< set main code
function setValue(itm,newValue: any,NoDelay: boolean?)
    if itm.Connection ~= nil and itm.Connection["Disconnect"] ~= nil then
        itm.Connection:Disconnect()
        itm.Connection = nil
    end;

    itm.ValueType = Utility.tof(newValue)
    local valueIsTable = itm.ValueType == "table"

    itm.valueIsValue = valueIsTable and ValueClasses[newValue.__type]
    itm.Value = newValue
    local function CallSignal(newValue: any,SkipDelay: boolean?)
        if itm.SignalEnabled == false then return end;
        itm.curentUsageId +=1;
        local currentId = itm.curentUsageId;
        local eqTime = itm.Time;
        if newValue ~= nil and itm.Custom ~= nil and itm.Custom[newValue] ~= nil then
            eqTime = itm.Custom[newValue];
        end
        if eqTime ~= nil and eqTime ~= 0 and SkipDelay == nil then
            if not itm.IsActive then return end
            task.wait(eqTime)
            if not itm.IsActive then return end
        end;
        if itm.IsSensitive == nil or currentId == itm.curentUsageId then
            itm.Changed:Fire(newValue)
        end
    end
    if valueIsTable and itm.valueIsValue then
        local init = newValue:Get()
        if NoDelay == nil then
            task.spawn(CallSignal,init)
        else
            CallSignal(init,true)
        end
        itm.Connection = newValue.Changed:Connect(function(newValue: any)
            CallSignal(newValue)
        end)
        return init;
    else
        if NoDelay == nil then
            task.spawn(CallSignal,newValue)
        else
            CallSignal(newValue,true)
        end
        return newValue;
    end
end
--> main set code
--[=[
    @method Set
    @within DelayValue
    @param newValue any
    Sets a new value.
    @return DelayValue
]=]
function mt:Set(newValue: any)
    setValue(self,newValue)
    return self
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
    
    Id += 1;
    local new = {
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
    new.Initial = setValue(new, Value,true)

    if Thread ~= nil then
        Utility.AddToThread(Thread,new)
    end
    return new;
end
