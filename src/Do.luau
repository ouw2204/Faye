local tf = table.find
local tr = table.remove
local tc = table.clear
local tof = typeof
local tins = table.insert
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Compile = require(script.Parent.Compile)

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
    }

    local Grab;
    local OnValueChanged;
    function Grab(Value)
        if Value == nil then return end;
        if Value == nil or tof(Value) ~= "table" or Value.__type == nil or ValueClasses[Value.__type] == nil then return end;
        if new.Listening[Value.Id] == nil then
            new.Listening[Value.Id] = true;
            tins(new.Connections,Value.Changed:Connect(OnValueChanged))
        end

        return Value:Get();
    end
    function OnValueChanged()
        local result = new.Function(Grab)
        if result ~= nil then
            if new.Property ~= nil then
                Compile(new.Entity,{[new.Property] = result})
            else
                Compile(new.Entity,{result})
            end
        end
    end
    

    function new:Initiate()
        OnValueChanged();
    end
    function new:Destroy()
        for k in ipairs(self.Connections) do
            self.Connections[k]:Disconnect();
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
        tc(self)
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