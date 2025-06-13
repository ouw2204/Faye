local scriptname = script.Name
local mt = {__type = scriptname};
local tins,tf,tr,tc = table.insert,table.find,table.remove,table.clear
mt.__index = mt;
local tof = typeof
local Clean = require(script.Parent.Clean)

local Compile = require(script.Parent.Compile)
--[=[
    @class Event
    Signal triggered compiler.
]=]
--[=[
    @class EventState
    Signal triggered compiler.
]=]

function  mt.__tostring()
    return scriptname;
end
--[=[
    @method Connect
    @within Event
    Connects a signal to the function
]=]
--[=[
    @method Connect
    @within EventState
    Connects a signal to the function
]=]
function mt:Connect(Signal)
    if self.__destroying then return end;
    if self.__Thread ~= nil then
        if self.__Thread["Add"] ~= nil then
            self.__Thread:Add(Signal:Connect(self.__prefunc),true)
        else
            local Connection = Signal:Connect(self.__prefunc)
            if typeof(Connection) == "table" and Connection.__simplesignalconnection and Connection.lists == nil then
                Connection.lists = self.__Thread;
            end
            tins(self.__Thread,Connection)
        end
    else
        Signal:Connect(self.__prefunc)
    end
end
--[=[
    @method Destroy
    @within Event
    Destroys the signal reader and cleans up resources.
]=]
--[=[
    @method Destroy
    @within EventState
    Destroys the signal reader and cleans up resources.
]=]
function  mt:Destroy()
    self.__destroying = true
    for i = #self,1,-1 do
        self[i]:Disconnect();
        self[i] = nil;
    end
    self.func = nil;
    if self.__Thread ~= nil then
        if self.__Thread["Remove"] ~= nil then
            self.__Thread:Remove(self)
        else
            local find = tf(self.__Thread,self)
            if find ~= nil then
                tr(self.__Thread,find)
            end
        end
        self.__Thread = nil
    end
    tc(self)
    setmetatable(self,nil)
    self.__destroying = nil
end
--[=[
    @method Call
    @within Event
    Forces a signal, only use this if the :Event is being compiled, otherwise just create a function then fire it.
]=]
--[=[
    @method Call
    @within EventState
    Forces a signal, only use this if the :Event is being compiled, otherwise just create a function then fire it.
]=]
function  mt:Call(...)
    if self.__Initiated == nil then
        if self.__callOnInit ~= nil then
            tc(self.__callOnInit)
        end
        self.__callOnInit = {...};
    else
        self.__prefunc(...)
    end
    return self;
end
local Types = require(script.Parent.Types);
--[=[
    @method SignalReader
    @within Thread
    Creates a new signal reader that will run the function when the signal is triggered.
]=]
return function (Connections: RBXScriptSignal & {RBXScriptSignal},func: () -> (), Thread: Types.Thread?,State: boolean?)
    local tab = {
        __func = func;
        __Thread = Thread;
        __entity = nil;
        __property = nil;
    }
    setmetatable(tab,mt)
    tab.__prefunc = function(...)
        if tab.__entity == nil or tab.__entity.Instance == nil then return end;
        if State then
            if tab.__currentcleaner ~= nil then
                if tab.__Thread["Remove"] then
                    tab.__Thread:Remove(tab.__currentcleaner)
                else
                    local pos = tf(tab.__Thread,tab.__currentcleaner)
                    if pos ~= nil then
                        tr(tab.__Thread,pos)
                    end
                end
                Clean(tab.__currentcleaner)
                tab.__currentcleaner = nil;
            end
            if tab.__Thread["Extend"] then
                tab.__currentcleaner = tab.__Thread:Extend();
            else
                tab.__currentcleaner = {};
                if tab.__Thread["Add"] then
                    tab.__Thread:Add(tab.__currentcleaner)
                else
                    tins(tab.__Thread,tab.__currentcleaner)
                end
            end
            tab.__currentcleaner._isCleanAncestor = tab.__Thread._isCleanAncestor
        end;
        local result,r1 = tab.__func(...)
        
        --[[
            The current cleaner is already added to the thread to be cleaned. the Entity instance is already in another object, therefor Entity: {} does not
            need a custom cleaning function, when it is sent to the cleaner the refenrecces in the table will be emptied, as for the contents are being deleted elsewhere.
        ]]
        if result ~= nil then
            local Entity = (State and {Instance = tab.__entity.Instance,Thread = tab.__currentcleaner}) or  tab.__entity;
            if tab.__property ~= nil then
                Compile(Entity,{[tab.__property] = result},tab.__currentcleaner)
            else
                if r1 ~= nil then
                    Compile(Entity,{[result] = r1},tab.__currentcleaner)
                else
                    Compile(Entity,{result},tab.__currentcleaner)
                end
            end
            Entity = nil;
        elseif State then
            --clean


            if tab.__Thread["Remove"] then
                tab.__Thread:Remove(tab.__currentcleaner)
            else
                local pos = tf(tab.__Thread,tab.__currentcleaner)
                if pos ~= nil then
                    tr(tab.__Thread,pos)
                end
            end
            Clean(tab.__currentcleaner)
            tab.__currentcleaner = nil;
            
        end
    end
    if Connections then
        if tof(Connections) == "table" and Connections.Connect == nil then
            for i = #Connections,1,-1 do
                tab:Connect(Connections[i])
                Connections[i] = nil;
            end
        else
            tab:Connect(Connections)
        end
    end
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(tab)
        else
            tins(Thread,tab)
        end
    end
    return tab
end