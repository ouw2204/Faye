--[=[
    @class Create
    A class that handles the creation of instances.
]=]

local PropertyTypes = require(script.Parent.Misc.PropertyTypes);
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Compilers = require(script.Parent.Compile.Compilers)
local Compile = require(script.Parent.Compile)
local Clean = require(script.Parent.Clean);
local Defaults = require(script.Defaults);

local tof = typeof
local tr = table.remove
local tins = table.insert
local tf = table.find

local mt = {__type = "Instance";}
mt.__index = mt;

local tc = table.clear
function removefunc(t: any, v: any)
    if t == nil or v == nil then return end;
    if t["Remove"] then
        return t:Remove(v)
    else
        local pos = tf(t,v)
        if pos ~= nil then
            tr(t,pos)
        end
    end
    return false
end

--[=[
    @method Compile
    @within Create
    Compiles the properties of the instance.
]=]
function mt:Compile()
    local Props = self.Props;
    if Props ~= nil then
        local AddClean = nil;
        if Props.CleanDelay ~= nil or Props.OnClean ~= nil then
            if self.Thread ~= nil then
                self.Thread._hc = true; --hc = hasclean
                self.Thread._isCleanAncestor = true;
            end;
            if self.InnerThread == nil then
                self.InnerThread = (self.Thread ~= nil and self.Thread:Extend(true)) or {}
                self.InnerThread._isCleanAncestor = true
            end
            
            if Props.CleanDelay ~= nil then
                self.CleanDelay = Props.CleanDelay
                Props.CleanDelay = nil;
            end
            if Props.OnClean ~= nil then
                self.OnClean = Props.OnClean;
                self.OnCleanCreated = true;
                Props.OnClean = nil;
            end
            if Props.CleanFunction ~= nil then
                AddClean = true;
            end
        else
            if Props.CleanFunction ~= nil then
                AddClean = true;
            end
        end
        if AddClean == true then
            if self.Thread ~= nil and self.Thread._isCleanAncestor then
                local f = Props.CleanFunction;
                local eq = self.Thread;
                local connected = {};
                local cf; cf = function()
                    if f == nil then return end;
                    f(self.InnerThread or self.Thread,self.Instance);
                    for i,v in pairs(connected) do
                        removefunc(v,cf)
                    end
                    f = nil;
                    tc(connected)
                    cf = nil;
                end
                eq:Add(cf)
                tins(connected,eq)
                if eq.ParentThread ~= nil then
                    local current = eq;
                    repeat
                        current = current.ParentThread
                        if current ~= nil and current._hc  then
                            current:Add(cf);
                            tins(connected,current);
                        end
                    until current == nil or current.ParentThread == nil
                    current = nil;
                end
            else
                self.CleanFunction = Props.CleanFunction
            end
        end
        AddClean = nil;
        Props.CleanFunction = nil;
        Props.CleanDelay = nil;

        if Props.Parent ~= nil then
            if typeof(Props.Parent) == "table" and Compilers[Props.Parent.__type] then
                Compilers[Props.Parent.__type](self,"Parent",Props.Parent)
            else
                self.Instance.Parent = Props.Parent;
            end
            Props.Parent = nil;
        end
        self.Props = nil;
        Compile(self,Props)
    else
        self:Destroy();
    end
end

--[=[
    @method Destroy
    @within Create
    Destroys the instance.
]=]
function mt:Destroy()
    if self.Thread ~= nil then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local Find = tf(self.Thread,self)
            if Find ~= nil then
                tr(self.Thread,Find) 
            end
        end
    end

    if self.CleanFunction ~= nil then
        self.CleanFunction(self.InnerThread or self.Thread,self.Instance)
        self.CleanFunction = nil;
    end 
    if self.OnClean ~= nil then
        if self.InnerThread["Add"] then
            self.InnerThread:Add(self.Instance)
        else
            table.insert(self.InnerThread,self.Instance)
        end
        self.OnClean(self.InnerThread,self.Instance);
        if self.InnerThread ~= nil then
            if self.InnerThread.AnimationsAmount == nil or self.InnerThread.AnimationsAmount <= 0 then
                Clean(self.InnerThread)
            else
                self.InnerThread.CleanWhenDone = true;
            end
            self.InnerThread = nil;
        end
        self.Instance = nil;
        self.OnClean = nil;
    else
        if self.CleanDelay ~= nil then
            task.delay(self.CleanDelay,function()
                self.Instance:Destroy();
                self.Instance = nil;
                Clean(self.InnerThread)
                self.CleanFunction = nil;
                self.OnClean = nil;
                self.InnerThread = nil;
                tc(self);
            end)
            self.CleanDelay = nil;
        else
            self.Instance:Destroy();
            self.Instance = nil;
            self.CleanFunction = nil;
            self.OnClean = nil;
            self.InnerThread = nil;
            tc(self);
        end
    end
    self.CleanDelay = nil;
    self.Props = nil;
    self.Thread = nil;
    setmetatable(self,nil)
end

local scriptName = script.Name;
function mt.__tostring()
    return scriptName;
end

--[=[
    @method Create
    @within Thread
    @param ClassName string
    @param Thread {Add: (self: {},Entity: any) -> ()}?
    @return (props: PropertyTypes.Property) -> Create
    [Creates a new instance object.](/docs/Instancing/Create)
]=]
return function(ClassName: string,Thread: {Add: (self: {},Entity: any) -> ()}?)
    return function(props: PropertyTypes.Property)
        local Object = Instance.new(ClassName);
        if Defaults[ClassName] ~= nil then
            Defaults[ClassName](Object)
        end

        local Simple = true;
        if props.Properties ~= nil then
            for i,v in pairs(props.Properties) do
                props[i] = v;
            end
            props.Properties = nil;
        end
        for i,v in pairs(props) do
            local tov= tof(v)
            if tov ~= "function" and tov ~= "table" and i ~= "CleanDelay" and tov ~= "Instance" then
                Object[i] = v;
                props[i] = nil;
            else
                Simple = false;
            end
        end
        
        if Simple then
            return Object;
        else
            props.ClearTableInCompulation = true;
            local Wrapper = {
                Instance = Object;
                Props = props;
                Thread = Thread;
            };
            setmetatable(Wrapper,mt);
            if props.Parent then
                Wrapper:Compile();
            end
            if Thread ~= nil then
                if Thread["Add"] then
                    Thread:Add(Wrapper)
                else
                    tins(Thread,Wrapper);
                end
            end
            return Wrapper;
        end
        
    end
end
