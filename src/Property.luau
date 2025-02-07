local Types = require(script.Parent.Types)
local mt = {};
mt.__index = mt;
local tof,tins,tr,tf = typeof,table.insert,table.remove,table.find
local tc = table.clear
local ValueClasses = require(script.Parent.Misc.ValueClasses)
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
    if New == nil then return end;
    if self.Instance ~= nil and self.Property ~= nil then
        if self.IsAttribute then
            self.Instance:SetAttribute(self.Property,New)
            return New
        else
            local tofIndex = tof(self.Instance[self.Property])
            local tofNew = tof(New)
            if tofIndex == tofNew or ((tofIndex == "number" or tofIndex == "string") and (tofNew == "number" or tofNew == "string")) then
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
    if self.PropConnect1 ~= nil then
        self.PropConnect1:Disconnect();
        self.PropConnect1 = nil;
    end
    if self.PropConnect2 ~= nil then
        self.PropConnect2:Disconnect();
        self.PropConnect2 = nil;
    end
    if self.Connect1 ~= nil then
        self.Connect1:Disconnect();
        self.Connect1 = nil;
    end
    if self.Connect2 ~= nil then
        self.Connect2:Disconnect();
        self.Connect2 = nil;
    end
    if self.Connect3 ~= nil then
        self.Connect3:Disconnect();
        self.Connect3 = nil;
    end
    tc(self)
end
return function(Entity: any,Property: any,IsAttribute: boolean,Thread: Types.Thread)
    if Entity == nil or Property == nil then return end;

    local new = {
        __type = script.Name;
        Connect1 = nil,Connect2 = nil; Connect3 = nil;
        PropConnect1 = nil;PropConnect2 = nil;
        Changed = Signal.new();
        Instance = nil;
        Property = nil;
        Initial = nil;
        IsAttribute = IsAttribute;
        Thread = Thread;
    }
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    
    local function upd()
        local Instance,Prop = new.Instance,new.Property
        if IsAttribute == false then
            new.Initial = Instance[Prop];
            new.Connect3 = Instance:GetPropertyChangedSignal(Prop):Connect(function()
                new.Changed:Fire(Instance[Prop])
            end)
        else
            new.Initial = Instance:GetAttribute(Prop);
            new.Connect3 = Instance:GetAttributeChangedSignal(Prop):Connect(function()
                new.Changed:Fire(Instance:GetAttribute(Prop))
            end)
        end
    end
    do--< Property
        local First = true;
        local function final(newv)
            if tof(newv) == "string" then
                if First == true then
                    new.Property = newv;
                    First = nil
                else
                    upd()
                end
            else
                warn(`Property must be a string or a value at the 1st-2nd degree which give a string - {debug.traceback()}`)
            end
        end
        local function Setup(newv)
            if new.PropConnect2 ~= nil then
                new.PropConnect2:Disconnect()
                new.PropConnect2 = nil;
            end
            if tof(newv) == "table" then
                if newv.__type ~= nil and ValueClasses[newv.__type] ~= nil then
                    final(newv:Get())
                    new.Connect2 = newv.Changed:Connect(final)
                end
            else
                final(newv)
            end
        end
        if tof(Property) == "table" then
            if Property.__type ~= nil and ValueClasses[Property.__type] then
                Setup(Property:Get())
                new.PropConnect1 = Property.Changed:Connect(Setup)
            end
        else
            Setup(Property)
        end
    end-->
    do--Entity
        local function FinalSetup(Worker)
            if new.Connect3 ~= nil then
                new.Connect3:Disconnect();
                new.Connect3 = nil;
            end
            local Type = tof(Worker)
            if Type == "Instance" then
                new.Instance = Worker
                upd();
            elseif Type == "table" then
                warn(`Entity must be an instance or a value at the 1st-2nd degree which give an Instance - {debug.traceback()}`)
            end
        end
        local function Setup(newV)
            if new.Connect2 ~= nil then
                new.Connect2:Disconnect();
                new.Connect2 = nil;
            end
            if new.Connect3 ~= nil then
                new.Connect3:Disconnect();
                new.Connect3 = nil;
            end
            if tof(newV) == "table" then
                if newV.__type ~= nil and ValueClasses[newV.__type] then
                    FinalSetup(newV:Get())
                    new.Connect2 = newV.Changed:Connect(FinalSetup)
                end
            else
                FinalSetup(newV)
            end
        end
        if tof(Entity) == "table" then
            if Entity.__type ~= nil and ValueClasses[Entity.__type] then
                Setup(Entity:Get())
                new.Connect1 = Entity.Changed:Connect(Setup)
            end
        else
            Setup(Entity)
        end
    end-->
    setmetatable(new,mt)
    return new;
end
