--[=[
    @class Property
    A class that represents a property with various actions and threading.
    `Add and Remove also work with the + and - operator. So Property + value, and  Property - value.`
]=]
local Types = require(script.Parent.Types)
local mt = {
    __type = script.Name;
};
mt.__index = mt;
local tof,tins,tr,tf = typeof,table.insert,table.remove,table.find
local tc = table.clear
local Signal = require(script.Parent.Packages.Signal)
local Actions = require(script.Parent.Misc.PropertyActions)

function mt.__add(tab,am)
    tab:Add(am)
    return tab;
end

function mt.__sub(tab,am)
    tab:Remove(am)
    return tab;
end

--[=[
    @method Add
    @within Property
    @param amount any
    Adds a value to the property.
]=]
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

--[=[
    @method Remove
    @within Property
    @param amount any
    Removes a value from the property.
]=]
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

--[=[
    @method Set
    @within Property
    @param New any
    Sets the property to a new value.
    @return any
]=]
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

--[=[
    @method Get
    @within Property
    @return any
    Returns the current value of the property.
]=]
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

--[=[
    @method Reset
    @within Property
    Resets the property to its initial value.
    @return any
]=]
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

--[=[
    @method Compare
    @within Property
    @param Value any
    @return boolean
    Compares the property value with the given value.
]=]
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
    @method Refresh
    @within Property
    Triggers the changed signal.
]=]
function mt:Refresh()
    if self.SignalEnabled == nil or self.SignalEnabled == true then
        self.Changed:Fire(self:Get())
    end
end
--[=[
    @method SetSignalEnabled
    @within Property
    @param Enabled boolean
]=]
function mt:SetSignalEnabled(Enabled: boolean)
    self.SignalEnabled = Enabled;
end
--[=[
    @method Destroy
    @within Property
    Destroys the property object and cleans up its resources.
]=]
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
    if self.ChangeListener ~= nil and self.ChangeListener["Disconnect"] ~= nil then
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
--[=[
    @method ReCalibrate
    @within Property
    Allows you to listen to a new property or new instance
]=]
function mt:ReCalibrate(Instance: Instance?,Property: string?)
    if Instance == nil or Property == nil then return end;
    if Instance ~= nil then
        self.Instance = Instance;
    end
    if Property ~= nil then
        self.Property = Property
    end
    if self.Instance == nil or self.Property == nil then return end;
    if self.ChangeListener ~= nil then
        self.ChangeListener:Disconnect();
        self.ChangeListener = nil;
    end
    if self.IsAttribute == false then
        self.Initial = self.Instance[self.Property];
        self.ChangeListener = self.Instance:GetPropertyChangedSignal(self.Property):Connect(function()
            if self.SignalEnabled == nil or self.SignalEnabled == true then
                self.Changed:Fire(self.Instance[self.Property])
            end
        end)
    else
        self.Initial = self.Instance:GetAttribute(self.Property);
        self.ChangeListener = self.Instance:GetAttributeChangedSignal(self.Property):Connect(function()
            if self.SignalEnabled == nil or self.SignalEnabled == true then
                self.Changed:Fire(self.Instance:GetAttribute(self.Property))
            end
        end)
    end
end
local Counter = 0;

--[=[
    @method Property
    @within Thread
    @param Entity any
    @param Property any
    @param IsAttribute boolean
    @param Thread Types.Thread
    @return Property
    Creates a new instance property sync.
]=]
return function(Entity: any,Property: any,IsAttribute: boolean,Thread: Types.Thread)
    local new = {
        Connect1 = nil,Connect2 = nil; Connect3 = nil;
        PropConnect1 = nil;PropConnect2 = nil;
        Changed = Signal.new();
        Instance = nil;
        Property = nil;
        Initial = nil;
        IsAttribute = IsAttribute;
        Thread = Thread;
        First = true;
        Id = `{script.Name}-{Counter}`;
        SignalEnabled = nil;
    }
    Counter +=1;
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    setmetatable(new,mt)
    new:ReCalibrate(Entity,Property)
    return new;
end
