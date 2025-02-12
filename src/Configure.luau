local PropertyTypes = require(script.Parent.Misc.PropertyTypes);

local Compile = require(script.Parent.Compile)
local Clean = require(script.Parent.Clean);
local ValueClasses = require(script.Parent.Misc.ValueClasses);
--
local tr = table.remove
local tins = table.insert
local tf = table.find
local tof = typeof
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
        self.OnClean(self.InnerThread,self.Instance);
        if self.InnerThread ~= nil then
            if self.InnerThread.AnimationsAmount == nil or self.InnerThread.AnimationsAmount <= 0 then
                Clean(self.InnerThread)
            else
                self.InnerThread.CleanWhenDone = true;
            end
            self.InnerThread = nil;
        end
        self.Instance:Destroy();
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
--exclusive to configure below
return function(Entity: any,Thread: {Add: (self: {},Entity: any) -> ()}?)
    return function(props: PropertyTypes.Property)
        if tof(Entity) == "table" then
            if Entity.__type == "Instance" then
                Entity = Entity.Instance;
            elseif ValueClasses[Entity.__type] then
                Entity = Entity:Get();
                if tof(Entity) == "table" and Entity.__type == "Instance" then
                    Entity = Entity.Instance;
                end
            end
        end
        if Entity == nil or tof(Entity) ~= "Instance" then warn(`Entity must be an instance for configure or a value that gives an instance - {debug.traceback()}`); return end;
        local Wrapper = {
            Instance = Entity;
            Props = props;
            Thread = Thread;
        };
        setmetatable(Wrapper,mt);
        Wrapper:Compile();
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
