local m = {};
m.__index = m;
local Utility = require(script.Parent.Utility);
local Actions = require(script.Parent.TypeActions)
local PropertyActions = require(script.Parent.PropertyActions)
--[[
local ValueTxt = "Value";
function  m.__tostring()
    return ValueTxt
end]]

function m.__sub(self,value)
    if value == nil then return self end;
    self:Remove(value)
    return self;
end

function m.__add(self,value)
    if value == nil then return self end;
    self:Add(value)
    return self;
end

function m:Remove(Value: any,...)
    if self.IsProperty then
        --| Prop/Attribute
        if self.Instance ~= nil and self.Property ~= nil then
            if self.IsAttribute then
                local Get = self.Instance:GetAttribute(self.Property)
                if Get == nil then
                    self.Instance:SetAttribute(self.Property,Value)
                else
                    local GetType = Utility.tof(Get)
                    if  PropertyActions.Attributes[GetType] and GetType == Utility.tof(Value) and PropertyActions.Attributes[GetType]["Remove"] ~= nil then
                        PropertyActions.Attributes[GetType].Remove(self.Instance,self.Property,Value)
                    end
                end
            else
                local Get = self.Instance[self.Property]
                do
                    local GetType = Utility.tof(Get)
                    if  PropertyActions.Property[GetType] and GetType == Utility.tof(Value) and PropertyActions.Property[GetType]["Remove"] ~= nil then
                        PropertyActions.Property[GetType].Remove(self.Instance,self.Property,Value)
                    end
                end
            end
        end
    else
        --| Regular Value
        local tofOnComing = Utility.tof(Value);
        if self.ValueType == "table" or self.ValueType == tofOnComing then
            if Actions[self.ValueType] ~= nil and Actions[self.ValueType]["Remove"] ~= nil then
                Actions[self.ValueType].Remove(self,Value,...)
            end
        else
            warn(`Type mismatch for removing - {debug.traceback()}`)
        end
    end
end

function m:Add(Value: any,...)
    if self.IsProperty then
        --| Prop/Attribute
        if self.Instance ~= nil and self.Property ~= nil then
            if self.IsAttribute then
                local Get = self.Instance:GetAttribute(self.Property)
                if Get == nil then
                    self.Instance:SetAttribute(self.Property,Value)
                else
                    local GetType = Utility.tof(Get)
                    if  PropertyActions.Attributes[GetType] and GetType == Utility.tof(Value) and PropertyActions.Attributes[GetType]["Add"] ~= nil then
                        PropertyActions.Attributes[GetType].Add(self.Instance,self.Property,Value)
                    end
                end
            else
                local Get = self.Instance[self.Property]
                do
                    local GetType = Utility.tof(Get)
                    if  PropertyActions.Property[GetType] and GetType == Utility.tof(Value) and PropertyActions.Property[GetType]["Add"] ~= nil then
                        PropertyActions.Property[GetType].Add(self.Instance,self.Property,Value)
                    end
                end
            end
        end
    else
        --| Regular Value
        local tofOnComing = Utility.tof(Value);
        if self.ValueType == "table" or self.ValueType == tofOnComing then
            if Actions[self.ValueType] ~= nil and Actions[self.ValueType]["Add"] ~= nil then
                Actions[self.ValueType].Add(self,Value,...)
            end
        else
            warn(`Type mismatch for adding - {debug.traceback()}`)
        end
    end
end

function m:SetSignalEnabled(Enabled: boolean)
    self.SignalEnabled = Enabled;
end

function m:Refresh()
    if self.SignalEnabled == nil or self.SignalEnabled == true then
        self.Changed:Fire(self:Get())
    end
end

function m:Reset()
    if self.IsProperty then
        --| Prop/Attribute
        if self.Instance ~= nil and self.Property ~= nil then
            if self.IsAttribute then
                self.Instance:SetAttribute(self.Property,self.Initial)
                return self.Initial
            else
                self.Instance[self.Property] = self.Initial;
                return self.Initial;
            end
        end
    else
        --| Regular Value
        if self.Value ~= self.Initial then
            self:Set(self.Initial)
        end
    end
end

function m:Compare(Value: any)
    if self.IsProperty then
        --| Prop/Attribute
        if self.Instance ~= nil and self.Property ~= nil then
            if self.IsAttribute then
                return self.Instance:GetAttribute(self.Property) == Value
            else
                return self.Instance[self.Property] == Value
            end
        end
    else
        --| Regular Value
        return self.Value == Value
    end
end

function m:GetItem(Index: any)
    if Index == nil then return end;
    if self.ValueTypeIsTable then
        return self.Value[Index]
    end
    return nil;
end

function m:ItemExists(Entity: any)
    if Entity == nil then return false end;
    if self.ValueTypeIsTable then
        return self.Value[Entity] ~= nil or table.find(self.Value,Entity) ~= nil
    end
    return false;
end

function m:Get()
    if self.IsProperty then
        --| Prop/Attribute
        if self.Instance ~= nil and self.Property ~= nil then
            if self.IsAttribute then
                return self.Instance:GetAttribute(self.Property)
            else
                return self.Instance[self.Property]
            end
        end
    else
        --| Regular Value
        if self.ValueTypeIsTable and self.Value ~= nil and self.Value.__type == Utility.instanceTxt then
            return self.Value.Instance
        end
        return self.Value
    end
end

function m:Set(newValue: any)
    if self.IsProperty then
        --| Prop/Attribute
        if self.Instance ~= nil and self.Property ~= nil then
            if self.IsAttribute then
                self.Instance:SetAttribute(self.Property,newValue)
                return newValue
            else
                local tofIndex = Utility.tof(self.Instance[self.Property])
                local tofNew = Utility.tof(newValue)
                if tofIndex == tofNew or ((tofIndex == "Instance" or tofIndex == "nil") and (tofNew == "Instance" or tofNew == "nil")) or ((tofIndex == "number" or tofIndex == "string") and (tofNew == "number" or tofNew == "string")) then
                    self.Instance[self.Property] = newValue;
                    return newValue;
                end
            end
        end
    else
        --| Regular Value
        if self.Value == newValue then return end;
        self.Value = newValue;
        self.ValueType = Utility.tof(newValue)
        self.ValueTypeIsTable = self.ValueType == Utility.tabletxt
        if self.SignalEnabled == true or self.SignalEnabled == nil then
            self.Changed:Fire(newValue)
        end
        return newValue;
    end
end


--| Prop/Attribute
function m:ReCalibrate(Instance: Instance?,Property: string?)
    
    if self.IsProperty then
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
        if self.IsAttribute == nil then
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
end
--|>
function m:Destroy()
    if self.Thread ~= nil then
        Utility.RemoveFromThread(self.Thread,self)
        self.Thread = nil;
    end
    if self.ChangeListener ~= nil then
        self.ChangeListener:Disconnect();
        self.ChangeListener = nil;
    end
    if self.Changed ~= nil then
        self.Changed:Destroy();
        self.Changed = nil;
    end 
    Utility.tc(self)
    setmetatable(self,nil)
end

return m;