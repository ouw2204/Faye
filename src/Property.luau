--[=[
    @class Property
]=]
local Types = require(script.Parent.Types)
local mt = {
    __type = script.Name;
};
mt.__index = mt;
local tof,tins,tr,tf = typeof,table.insert,table.remove,table.find
local tc = table.clear
local Signal = require(script.Parent.Packages.Signal)
local Actions = require(script.Parent.Misc.PropertyAttributeActions)
function mt.__add(tab,am)
    tab:Add(am)
    return tab;
end
function mt.__sub(tab,am)
    tab:Remove(am)
    return tab;
end
--add
function mt:Add(amount)
    if self.Instance ~= nil and self.Property ~= nil then
        if self.IsAttribute then
            local Get = self.Instance:GetAttribute(self.Property)
            if Get == nil then
                self.Instance:SetAttribute(self.Property,amount)
            else
                local GetType = tof(Get)
                if  Actions.Attributes[GetType] and GetType == tof(amount) and Actions.Attributes[GetType]["Add"] ~= nil then
                    Actions.Attributes[GetType].Add(self.Instance,self.Property,amount)
                end
            end
        else
            local Get = self.Instance[self.Property]
            do
                local GetType = tof(Get)
                if  Actions.Property[GetType] and GetType == tof(amount) and Actions.Property[GetType]["Add"] ~= nil then
                    Actions.Property[GetType].Add(self.Instance,self.Property,amount)
                end
            end
        end
    end
end
--remove
function mt:Remove(amount)
    if self.Instance ~= nil and self.Property ~= nil then
        if self.IsAttribute then
            local Get = self.Instance:GetAttribute(self.Property)
            if Get == nil then
                self.Instance:SetAttribute(self.Property,amount)
            else
                local GetType = tof(Get)
                if  Actions.Attributes[GetType] and GetType == tof(amount) and Actions.Attributes[GetType]["Remove"] ~= nil then
                    Actions.Attributes[GetType].Remove(self.Instance,self.Property,amount)
                end
            end
        else
            local Get = self.Instance[self.Property]
            do
                local GetType = tof(Get)
                if  Actions.Property[GetType] and GetType == tof(amount) and Actions.Property[GetType]["Remove"] ~= nil then
                    Actions.Property[GetType].Remove(self.Instance,self.Property,amount)
                end
            end
        end
    end
end
--set
function mt:Set(New)
    if self.Instance ~= nil and self.Property ~= nil then
        if self.IsAttribute then
            self.Instance:SetAttribute(self.Property,New)
            return New
        else
            local tofIndex = tof(self.Instance[self.Property])
            local tofNew = tof(New)
            if tofIndex == tofNew or ((tofIndex == "Instance" or tofIndex == "nil") and (tofNew == "Instance" or tofNew == "nil")) or ((tofIndex == "number" or tofIndex == "string") and (tofNew == "number" or tofNew == "string")) then
                self.Instance[self.Property] = New;
                return New;
            end
        end
    end
    return;
end
--get
function mt:Get()
    if self.Instance ~= nil and self.Property ~= nil then
        if self.IsAttribute then
            return self.Instance:GetAttribute(self.Property)
        else
            return self.Instance[self.Property]
        end
    end
    return nil;
end

function mt:Reset()
    local New = self.Initial;
    if self.Instance ~= nil and self.Property ~= nil then
        if self.IsAttribute then
            self.Instance:SetAttribute(self.Property,New)
            return New
        else
            self.Instance[self.Property] = New;
            return New;
        end
    end
    return;
end


function mt:Compare(Value: any)
    if self.Instance ~= nil and self.Property ~= nil then
        if self.IsAttribute then
            return self.Instance:GetAttribute(self.Property) == Value
        else
            return self.Instance[self.Property] == Value
        end
    end
    return false
end
--[=[
    @within Property
    @method Refresh
    Triggers changed signal
]=]
function mt:Refresh()
    self.Changed:Fire(self:Get())
end
function mt:Destroy()
    if self.Thread ~= nil then
        if self.Thread["Remove"] ~= nil then
            self.Thread:Remove(self)
        else
            local pos = tf(self.Thread,self)
            if pos ~= nil then
                tr(self.Thread,pos)
            end
        end
        self.Thread = nil;
    end
    if self.Changed ~= nil then
        self.Changed:Destroy()
        self.Changed = nil;
    end
    if self.ChangeListener ~= nil then
        self.ChangeListener:Disconnect();
        self.ChangeListener = nil;
    end
    tc(self)
    setmetatable(self,nil);
end
local scriptName = script.Name;
function mt.__tostring()
    return scriptName;
end
local Counter = 0;
return function(Entity: any,Property: any,IsAttribute: boolean,Thread: Types.Thread)
    if Entity == nil or Property == nil then warn(`Entity and Property parameter must exist - {debug.traceback()}`); return end;
    if not (tof(Entity) == "Instance" and tof(Property) == "string") then warn(`Entity param must be an instance and Proeprty param must be a string - {debug.traceback()}`); return end;
    local new = {
        Connect1 = nil,Connect2 = nil; Connect3 = nil;
        PropConnect1 = nil;PropConnect2 = nil;
        Changed = Signal.new();
        Instance = Entity;
        Property = Property;
        Initial = nil;
        IsAttribute = IsAttribute;
        Thread = Thread;
        First = true;
        Id = `{script.Name}-{Counter}`
    }
    Counter +=1;
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    if IsAttribute == false then
        new.Initial = Entity[Property];
        new.ChangeListener = Entity:GetPropertyChangedSignal(Property):Connect(function()
            new.Changed:Fire(Entity[Property])
        end)
    else
        new.Initial = Entity:GetAttribute(Property);
        new.ChangeListener = Entity:GetAttributeChangedSignal(Property):Connect(function()
            new.Changed:Fire(Entity:GetAttribute(Property))
        end)
    end
    setmetatable(new,mt)
    return new;
end
