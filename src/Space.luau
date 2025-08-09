local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
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
    @method Connect
    @within Task
    Connects a signal to the task. The task will be called when the signal is fired.
]=]

function parammt:Connect(Connection: RBXScriptSignal)
    if self.__connections == nil then
        self.__connections = {}
    end
    local connection = Connection:Connect(self.Call,self.__connections)
    Utility.tins(self.__connections,connection)
    return connection;
end
--[=[
    @method AddParameter
    @within Task
    Cleans up the task and removes it from the Space. This will also disconnect any connections made to the task.
]=]
function parammt:AddParameter(Index: any,Value: any)
    if (Value == nil and Index == nil) or Index == nil then return end;
    if Value ~= nil then
        self[Index] = Value;
    else
        Utility.tins(self,Index)
    end
    return self;
end
--[=[
    @method Destroy
    @within Task
    Cleans up the task and removes it from the Space. This will also disconnect any connections made to the task.
]=]
function parammt:Destroy()
    local f = Utility.tf(self.__holder.Tasks,self)
    if f ~= nil then
        Utility.tr(self.__holder.Tasks,f)
    end
    if self.__thread ~= nil then
        Utility.RemoveFromThread(self.__thread,self)
    end
    if self.__connections ~= nil then
        for i = #self.__connections,1,-1 do
            self.__connections[i]:Disconnect()
            self.__connections[i] = nil;
        end
    end
    self.__holder = nil;
    self.Call = nil;
    Utility.tc(self)
    setmetatable(self,nil)
end
--[=[
    @method Call
    @within Space
    Calls all tasks in the Space.
]=]
function mt:Call()
    if self.Cleaning then return end;
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
function mt:Add(Params: {[any]: any},Thread: Types.Thread,NoUnpack: boolean?)
    if self.Cleaning == true then return end;
    if Params == nil then Params = {}; end;
    Thread = Thread or self.Thread;
    Params.__holder = self;
    Params.__thread = Thread;
    --[=[
        @method Call
        @within Task
        Executes the task.
    ]=]
    function Params.Call()
        if NoUnpack then
            Params.__holder.func(Params)
        else
            Params.__holder.func(table.unpack(Params))
        end
        return Params;
    end
    if Thread ~= self.Thread then
        Utility.AddToThread(Thread,Params)
    end

    setmetatable(Params,parammt);
    Utility.tins(self.Tasks,Params)
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
    local find = Utility.tf(self.Tasks,Task)
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
    if self.Cleaning then return end;
    if Id == nil then
        local connectedConnection = Connection:Connect(self.ReceiverFunction,self.Thread)
        Utility.AddToThread(self.Thread,connectedConnection)
        return connectedConnection;
    else
        task.spawn(function()
            task.wait()
            if self.Tasks == nil or self.Cleaning then  return end;
            for i = 1,#self.Tasks do
                if self.Tasks[i].Id == Id then
                    if self.Tasks[i].__connections == nil then
                        self.Tasks[i].__connections = {}
                    end
                    local TaskConnection = Connection:Connect(self.Tasks[i].Call,self.Tasks[i].__connections)
                    Utility.tins(self.Tasks[i].__connections,TaskConnection)
                    return TaskConnection;
                end
            end
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
        Utility.RemoveFromThread(self.Thread,self)
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
        for _,v in pairs(m.Tasks) do
            v.Call();
        end
    end
    if Thread ~= nil then
        Utility.AddToThread(Thread,m)
    end
    setmetatable(m,mt)
    return m;
end