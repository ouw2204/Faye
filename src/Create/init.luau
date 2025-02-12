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
function mt:Compile()
    local Props = self.Props;
    if Props ~= nil then
        self.Props = nil;
        if Props.OnClean ~= nil then
            self.InnerThread = (self.Thread ~= nil and self.Thread:Extend(true)) or {}
            self.OnClean = Props.OnClean;
            Props.OnClean = nil;
        end
        Compile(self,Props)
    else
        self:Destroy();
    end
end

--Destroy function
function mt:Destroy()
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
        self.Instance:Destroy();
        self.Instance = nil;
    end
    self.Props = nil;
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
