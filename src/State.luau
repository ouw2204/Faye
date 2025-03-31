--[=[
    @class State
    A class that handles state management.
]=]

local Clean = require(script.Parent.Clean)
local tf = table.find
local tr = table.remove
local tc = table.clear
local tins = table.insert
local Compile = require(script.Parent.Compile)


local mt = {
    __type = script.Name;
}
mt.__index = mt;

--[=[
    @method Destroy
    @within State
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
    if self.CurrentCleaner ~= nil then
        --< remove current cleaner from table
        if self.Thread ~= nil then
            if self.Thread["Remove"] ~= nil then
                self.Thread:Remove(self.CurrentCleaner)
            else
                local find = tf(self.Thread,self.CurrentCleaner)
                if find ~= nil then
                    tr(self.Thread,find)
                end
            end
        end
        --> remove current cleaner from table
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

--[=[
    @method State
    @within Thread
    @param FunctionToFire function
    @param Thread any?
    @return State
    [Creates a new State object that manages the given function.](/docs/Utilities/State)
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
        CurrentCleaner = nil;
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
        if new.Entity == nil or new.Entity.Instance == nil then return end;
        if new.CurrentCleaner ~= nil then
            if new.Thread["Remove"] then
                new.Thread:Remove(new.CurrentCleaner)
            else
                local pos = tf(new.Thread,new.CurrentCleaner)
                if pos ~= nil then
                    tr(new.Thread,pos)
                end
            end
            Clean(new.CurrentCleaner)
            new.CurrentCleaner = nil;
        end
        new.CurrentCleaner = new.Thread:Extend();
        new.CurrentCleaner._isCleanAncestor = new.Thread._isCleanAncestor
        local result,r1 = new.Function(new.Grab,new.CurrentCleaner,(new.Entity ~= nil and new.Entity.Instance) or nil )
        
        --[[
            The current cleaner is already added to the thread to be cleaned. the Entity instance is already in another object, therefor Entity: {} does not
            need a custom cleaning function, when it is sent to the cleaner the refenrecces in the table will be emptied, as for the contents are being deleted elsewhere.
        ]]
        if result ~= nil then
            local Entity = {Instance = new.Entity.Instance,Thread = new.CurrentCleaner};
            if new.Property ~= nil then
                Compile(Entity,{[new.Property] = result},new.CurrentCleaner)
            else
                if r1 ~= nil then
                    Compile(Entity,{[result] = r1},new.CurrentCleaner)
                else
                    Compile(Entity,{result},new.CurrentCleaner)
                end
            end
        else
            --clean


            if new.Thread["Remove"] then
                new.Thread:Remove(new.CurrentCleaner)
            else
                local pos = tf(new.Thread,new.CurrentCleaner)
                if pos ~= nil then
                    tr(new.Thread,pos)
                end
            end
            Clean(new.CurrentCleaner)
            new.CurrentCleaner = nil;
            
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