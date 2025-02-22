
--[=[
    @class Value
    A class that represents a reactive state value. Values can be created with Threads(recommended) or directely by the value class.
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
    @within Value
    @method Add
    @param Value any
    This method works with numbers, strings, vectors, UDims, and tables.
]=]
function mt:Add(Value: any,...)
    local tofCurrent = typeof(self.Value);
    local tofOnComing = typeof(Value);
    if tofCurrent == "table" or tofCurrent == tofOnComing then
        if Actions[tofCurrent] ~= nil and Actions[tofCurrent]["Add"] ~= nil then
            Actions[tofCurrent].Add(self,Value,...)
        end
    else
        warn(`Type mismatch for adding - {debug.traceback()}`)
    end
end
--[=[
    @within Value
    @method Remove
    @param Value any
    This method works with numbers, vectors, UDims, and tables.
]=]
function mt:Remove(Value: any,...)
    local tofCurrent = typeof(self.Value);
    local tofOnComing = typeof(Value);
    if tofCurrent == "table" or tofCurrent == tofOnComing then
        if Actions[tofCurrent] ~= nil and Actions[tofCurrent]["Remove"] ~= nil then
            Actions[tofCurrent].Remove(self,Value,...)
        end
    else
        warn(`Type mismatch for removing - {debug.traceback()}`)
    end
end
--[=[
    @within Value
    @method Set
    @param Value any
    Sets the value.
]=]
function mt:Set(newValue: any)
    if self.Value ~= newValue then
        self.Value = newValue;
        self.Changed:Fire( (newValue == nil and "NULL") or newValue )
    end
    return newValue;
end
--[=[
    @within Value
    @method Get
    @return any
    Returns the current value.
]=]
function mt:Get()
    local Ret = (self.Value == nil and "NULL") or self.Value;
    if Ret ~= nil and tof(Ret) == "table" and Ret.__type == "Instance" then
        Ret = Ret.Instance
    end
    return Ret
end
--[=[
    @within Value
    @method Compare
    @param Value any
    @return boolean
    Compares the value passed with the value's current state.
]=]
function mt:Compare(Value: any)
    return self.Value == Value
end
--[=[
    @within Value
    @method Reset
    This method resets the value to its initial state.
]=]
function mt:Reset()
    self:Set(self.Initial)
end
--[=[
    @within Value
    @method Destroy
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
    self.__type = nil;
    self.Value = nil;
    self.Initial = nil;
    self.Id = nil;
    tc(self)
    setmetatable(self,nil);
end
mt.__tostring = function(self)
    return `Value: {self.Id}`
end
local Counter = 0;
return function (Initial: any,Thread: {Add: (self: any, Entity: any) -> ()}?)
    Counter += 1
    local new = {
        __type = script.Name;
        Value = Initial;
        Thread = Thread;
        Initial = Initial;
        Changed = Signal.new();
        Id = `{script.Name}-{Counter}`
    }
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
