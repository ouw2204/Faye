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
function mt:Set(newValue: any)
    if self.Value ~= newValue then
        self.Value = newValue;
        self.Changed:Fire( (newValue == nil and "NULL") or newValue )
    end
    return newValue;
end
function mt:Get()
    local Ret = (self.Value == nil and "NULL") or self.Value;
    if Ret ~= nil and tof(Ret) == "table" and Ret.__type == "Instance" then
        Ret = Ret.Instance
    end
    return Ret
end

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
    self.Changed:Destroy();
    self.Changed = nil;
    self.Value = nil;
    self.Initial = nil;
    tc(self)
    setmetatable(self,nil);
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
        Id = Counter
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
