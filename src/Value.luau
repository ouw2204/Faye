--[=[
    @class Value
    A class that represents a reactive state value. Values can be created with Threads(recommended) or directly by the value class.
]=]

local Signal = require(script.Parent.Packages.Signal);
local tins,tf,tr = table.insert,table.find,table.remove
local tof = typeof
local tc = table.clear

local Actions = require(script.Parent.Misc.ValueTypeActions);

local mt = {};
mt.__index = mt;

function mt.__sub(self,value)
    if value == nil then return end;
    self:Remove(value)
    return self;
end

function mt.__add(self,value)
    if value == nil then return end;
    self:Add(value)
    return self;
end

--[=[
    @method Add
    @within Value
    @param Value any
    This method works with numbers, strings, vectors, UDims, and tables.
]=]
function mt:Add(Value: any,...)
    local tofOnComing = typeof(Value);
    if self.ValueType == "table" or self.ValueType == tofOnComing then
        if Actions[self.ValueType] ~= nil and Actions[self.ValueType]["Add"] ~= nil then
            Actions[self.ValueType].Add(self,Value,...)
        end
    else
        warn(`Type mismatch for adding - {debug.traceback()}`)
    end
end

--[=[
    @method Remove
    @within Value
    @param Value any
    This method works with numbers, vectors, UDims, and tables.
]=]
function mt:Remove(Value: any,...)
    local tofOnComing = typeof(Value);
    if self.ValueType == "table" or self.ValueType == tofOnComing then
        if Actions[self.ValueType] ~= nil and Actions[self.ValueType]["Remove"] ~= nil then
            Actions[self.ValueType].Remove(self,Value,...)
        end
    else
        warn(`Type mismatch for removing - {debug.traceback()}`)
    end
end

--[=[
    @method Set
    @within Value
    @param Value any
    Sets the value.
]=]
function mt:Set(newValue: any)
    if self.SignalEnabled == true or self.SignalEnabled == nil then
        if self.Value ~= newValue then
            self.Value = newValue;
            self.Changed:Fire(newValue)
        end
    end
    self.ValueType = tof(newValue)
    return newValue;
end

--[=[
    @method Get
    @within Value
    @return any
    Returns the current value.
]=]
function mt:Get()
    local Ret = self.Value;
    if self.ValueType == "table" and Ret ~= nil and Ret.__type == "Instance" then
        Ret = Ret.Instance
    end
    return Ret
end

--[=[
    @method Compare
    @within Value
    @param Value any
    @return boolean
    Compares the value passed with the value's current state.
]=]
function mt:Compare(Value: any)
    return self.Value == Value
end

--[=[
    @method Reset
    @within Value
    This method resets the value to its initial state.
]=]
function mt:Reset()
    self:Set(self.Initial)
end

--[=[
    @method Destroy
    @within Value
    Destroys the value object.
]=]
function mt:Destroy()
    if self.Thread ~= nil then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local find = tf(self.Thread,self)
            if find ~= nil then
                tr(self.Thread,find)
            end
        end
        self.Thread = nil;
    end
    if self.Changed ~= nil then
        self.Changed:Destroy()
        self.Changed = nil;
    end
    self.ValueType = nil;
    self.__type = nil;
    self.Value = nil;
    self.Initial = nil;
    self.Id = nil;
    tc(self)
    setmetatable(self,nil);
end

--[=[
    @method Refresh
    @within Value
    Triggers changed signal.
]=]
function mt:Refresh()
    if self.SignalEnabled == nil or self.SignalEnabled == true then
        self.Changed:Fire(self:Get())
    end
end
--[=[
    @method SetSignalEnabled
    @within Value
    @param Enabled boolean
]=]
function mt:SetSignalEnabled(Enabled: boolean)
    self.SignalEnabled = Enabled;
end
mt.__tostring = function(self)
    return `Value: {self.Id}`
end

local Counter = 0;

--[=[
    @method Value
    @within Thread
    @param Initial any
    @param Thread {Add: (self: any, Entity: any) -> ()}?
    @return Value
    [Creates a new value object.](/docs/Utilities/Value)
]=]
return function (Initial: any,Thread: {Add: (self: any, Entity: any) -> ()}?)
    local new = {
        __type = script.Name;
        ValueType = tof(Initial);
        Value = Initial;
        Thread = Thread;
        Initial = Initial;
        Changed = Signal.new();
        Id = `{script.Name}-{Counter}`
    }
    Counter += 1
    setmetatable(new,mt)
    if Thread ~= nil then
        if Thread["Add"] ~= nil then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new;
end
