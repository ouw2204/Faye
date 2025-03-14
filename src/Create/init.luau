local PropertyTypes = require(script.Parent.Misc.PropertyTypes);

local Compile = require(script.Parent.Compile)
local Clean = require(script.Parent.Clean);
local Defaults = require(script.Defaults);

--
local tr = table.remove
local tins = table.insert
local tf = table.find


local mt = {__type = "Instance";}
mt.__index = mt;


--Object open function
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

function mt:Compile()
    local Props = self.Props;
    if Props ~= nil then
        if Props.Parent ~= nil then
            self.Instance.Parent = Props.Parent;
            Props.Parent = nil;
        end
        self.Props = nil;
        local AddClean = nil;
        if Props.CleanDelay ~= nil or Props.OnClean ~= nil then
            self.Thread._hc = true; --hc = hasclean
            self.Thread._isCleanAncestor = true;
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
            if self.Thread._isCleanAncestor then
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
        Compile(self,Props)
    else
        self:Destroy();
    end
end

--Destroy function
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
        --< run the on clean function
        self.InnerThread:Add(self.Instance)
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
        --> run the onclean function
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
--exclusive to create below
return function(ClassName: string,Thread: {Add: (self: {},Entity: any) -> ()}?)
    return function(props: PropertyTypes.Property)
        local Object = Instance.new(ClassName);
        if Defaults[ClassName] ~= nil then
            Defaults[ClassName](Object)
        end
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
