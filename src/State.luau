local Clean = require(script.Parent.Clean)
local tf = table.find
local tr = table.remove
local tc = table.clear
local tof = typeof
local tins = table.insert
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Compile = require(script.Parent.Compile)


local mt = {}
mt.__index = mt;


function mt:Initiate()
    task.spawn(self.OnValueChanged);
end
function mt:Destroy()
    for i = #self.Connections,1,-1 do
        self.Connections[i]:Disconnect()
        self.Connections[i] = nil;
    end
    if self.CurrentCleaner ~= nil then
        Clean(self.CurrentCleaner)
        self.CurrentCleaner = nil;
    end
    tc(self.Connections)
    tc(self.Listening)
    self.Connections = nil
    self.Listening = nil
    
    if self.Thread ~= nil then
        if self.Thread["Remove"] ~= nil then
            self.Thread:Remove(self)
        else
            local find = tf(self.Thread,self)
            if find ~= nil then
                tr(self.Thread,find)
            end
        end
        self.Thread = nil
    end
    self.Property = nil;
    self.Entity = nil;
    self.Function = nil
    self.Grab = nil;
    self.OnValueChanged = nil;
    tc(self)
    setmetatable(self,nil);
end

local scriptName = script.Name;
function mt.__tostring()
    return scriptName;
end
return function(FunctionToFire,Thread)
    if FunctionToFire == nil then return  end;
    
    local new = {
        __type = script.Name;
        Thread = Thread;
        Function = FunctionToFire;
        Listening = {};
        Connections = {};
        Property = nil;
        Entity = nil;
        CurrentCleaner = nil;
    }
    setmetatable(new,mt);
    function new.Grab(Value)
        if Value == nil then return end;
        if Value == nil or tof(Value) ~= "table" or Value.__type == nil or ValueClasses[Value.__type] == nil then return end;
        if new.Listening[Value.Id] == nil then
            new.Listening[Value.Id] = true;
            tins(new.Connections,Value.Changed:Connect(new.OnValueChanged))
        end

        return Value:Get();
    end
    function new.OnValueChanged()
        if new.Entity == nil or new.Entity.Instance == nil then return end;
        if new.CurrentCleaner ~= nil then
            if Thread["Remove"] then
                Thread:Remove(new.CurrentCleaner)
            else
                local pos = tf(Thread,new.CurrentCleaner)
                if pos ~= nil then
                    tr(Thread,pos)
                end
            end
            Clean(new.CurrentCleaner)
            new.CurrentCleaner = nil;
        end
        new.CurrentCleaner = new.Thread:Extend();
        local result,r1 = new.Function(new.Grab,new.CurrentCleaner,(new.Entity ~= nil and new.Entity.Instance) or nil )
        local Entity = {Instance = new.Entity.Instance,Thread = new.CurrentCleaner};
        --[[
            The current cleaner is already added to the thread to be cleaned. the Entity instance is already in another object, therefor Entity: {} does not
            need a custom cleaning function, when it is sent to the cleaner the refenrecces in the table will be emptied, as for the contents are being deleted elsewhere.
        ]]
        if result ~= nil then
            if new.Property ~= nil then
                Compile(Entity,{[new.Property] = result})
            else
                if r1 ~= nil then
                    Compile(Entity,{[result] = r1})
                else
                    Compile(Entity,{result})
                end
            end
        end
    end

    if Thread~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new :: any;

end