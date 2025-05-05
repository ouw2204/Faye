--[=[
    @class Do
    A class that handles the execution of functions.
]=]

local tf = table.find
local tr = table.remove
local tc = table.clear
local tof = typeof
local tins = table.insert
local Compile = require(script.Parent.Compile)


local mt = {
    __type = script.Name;
}
mt.__index = mt;

--[[
    @method Run
    @within Do
    Runs the do block manuelly.
]]
function mt:Run()
    task.spawn(self.OnValueChanged)
    return self;
end
--[=[
    @method Destroy
    @within Do
    Destroys the object and cleans up resources.
]=]
function mt:Destroy()
    for i = #self.Connections,1,-1 do
        local Connection = self.Connections[i]
        self.Connections[i] = nil;
        if Connection["Disconnect"] ~= nil then
            Connection:Disconnect()
        end
        Connection = nil;
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

--[=[
    @method Do
    @within Thread
    @param () -> (), Thread: Thread?
    @return Do
    Creates a new Do object that executes the given function.
]=]
return function(FunctionToFire,Thread)
    if FunctionToFire == nil then return  end;
    local new = {
        Thread = Thread;
        Function = FunctionToFire;
        Listening = {};
        Connections = {};
        Property = nil;
        Entity = nil;
    }
    setmetatable(new,mt);
    function new.Grab(Value)
        if Value == nil then return end;
        if new.Listening[Value.Id] == nil then
            new.Listening[Value.Id] = true;
            tins(new.Connections,Value.Changed:Connect(new.OnValueChanged))
        end

        return Value:Get();
    end
    function new.OnValueChanged()
        local result,r1 = new.Function(new.Grab,(new.Entity ~= nil and new.Entity.Instance) or nil )
        if result ~= nil and new.Entity ~= nil then
            if new.Property ~= nil then
                if tof(result) == "table" then
                    Compile(new.Entity,{[new.Property] = result})
                else
                    new.Entity.Instance[new.Property] = result;
                end
            else
                if r1 ~= nil then
                    Compile(new.Entity,{[result] = r1})
                else
                    Compile(new.Entity,{result})
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