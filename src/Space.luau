local tins = table.insert
local tc = table.clear
local tf = table.find
local tr = table.remove
--[=[
    @class Space
    A code runner that helps manage multiple [tasks](./Task)/components to avoid excessive code/connections running at once.
]=]
local mt = {};
mt.__index = mt;
--[=[

    @class Task
    A task that is added to the Space. It can be called and removed from the Space.
]=]
local parammt = {};
parammt.__index = parammt;
--[=[
    @method SetId
    @within Task
    @param Id string
    Sets a unique ID for the task. This ID can be used to identify the task later.
]=]
function parammt:SetId(Id: string)
    self.Id = Id;
    return self;
end
--[=[
    @method Destroy
    @within Task
    Cleans up the task and removes it from the Space. This will also disconnect any connections made to the task.
]=]
function parammt:Destroy()
    local f = tf(self.__holder.Tasks,self)
    if f ~= nil then
        tr(self.__holder.Tasks,f)
    end
    if self.__thread ~= nil then
        if self.__thread["Remove"] then
            self.__thread:Remove(self)
        else
            local f2 = tf(self.__thread,self)
            if f2 ~= nil then
                tr(self.__thread,f2)
            end
        end
    end
    if self.__connections ~= nil then
        for i = #self.__connections,1,-1 do
            self.__connections[i]:Disconnect()
            self.__connections[i] = nil;
        end
    end
    self.__holder = nil;
    self.Call = nil;
    tc(self)
    setmetatable(self,nil)
end

local Types = require(script.Parent.Types)
--[=[
    @method Call
    @within Space
    Calls all tasks in the Space.
]=]
function mt:Call()
    if self.Cleaning == true then return end;
    for i = #self.Tasks,1,-1 do
        self.Tasks[i].Call();
    end
    return self;
end
--[=[
    @method Add
    @within Space
    @param Params {[any]: any}
    @param Thread Thread?
    Adds/Creates a task to the Space. The task will be called when the Space is called.
]=]
function mt:Add(Params: {[any]: any},Thread: Types.Thread)
    if self.Cleaning == true then return end;
    if Params == nil then return end;
    Thread = Thread or self.Thread;
    Params.__holder = self;
    Params.__thread = Thread;
    --[=[
        @method Call
        @within Task
        Executes the task.
    ]=]
    function Params.Call()
        Params.__holder.func(table.unpack(Params))
        return Params;
    end
    if Thread ~= self.Thread then
        if Thread["Add"] then
            Thread:Add(Params)
        else
            tins(Thread,Params)
        end
    end
    setmetatable(Params,parammt);
    tins(self.Tasks,Params)
    return Params;
end
--[=[
    @method Remove
    @within Space
    @param Task Task
    Removes a task from the Space. The task will no longer be called when the Space is called.
]=]
function mt:Remove(Task)
    if self.Cleaning == true then return end;
    if Task == nil then return end;
    local find = tf(self.Tasks,Task)
    if find ~= nil then
        self.Tasks[find]:Destroy();
    end
end
--[=[
    @method Connect
    @within Space
    @param Connection RBXScriptSignal
    @param Id string?
    Connects a signal to space, pass an id if u only want that connection to fire a specific task.
]=]
function mt:Connect(Connection: RBXScriptSignal,Id: string?)
    if Id == nil then
        local connection = Connection:Connect(self.ReceiverFunction)
        self.Thread:Add(connection)
        return connection;
    else
        task.delay(nil,function()
            for i,v in pairs(self.Tasks) do
                if v.Id == Id then
                    local TaskConnection = Connection:Connect(v.Call)
                    if v.__connections == nil then
                        v.__connections = {}
                    end
                    tins(v.__connections,TaskConnection)
                    return TaskConnection;
                end
            end
            return
        end)
    end
    return
end
--[=[
    @method Destroy
    @within Space
    Cleans up the Space and removes all tasks. This will also disconnect any connections made to the Space.
]=]
function mt:Destroy()
    self.Cleaning = true;
    self.func = nil;
    self.ReceiverFunction = nil;

    if self.Thread ~= nil then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local f = tf(self.Thread,self)
            if f ~= nil then
                tr(self.Thread,f)
            end
        end
        self.Thread = nil;
    end
    for i = #self.Tasks,1,-1 do
        self.Tasks[i]:Destroy();
    end
    self.Tasks = nil;
    self.Cleaning = nil;
    setmetatable(self,nil);
end
local Name = script.Name;
function mt.__tostring()
    return Name;
end
--[=[
    @method Space
    @within Thread
    @param func function
    @param Thread Thread?
    Creates a new Space object. The space will call the function when the space is called.
]=]
return function(func: (...any) -> (),Thread: Types.Thread)
    local m = {
        func = func;
        Thread = Thread;
        Tasks = {};
        Cleaning = nil;

    };
    m.ReceiverFunction = function()
        if m.Cleaning then return end;
        for i,v in pairs(m.Tasks) do
            m.func(table.unpack(v))
        end
    end
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(m)
        else
            tins(Thread,m)
        end
    end
    setmetatable(m,mt)
    return m;
end