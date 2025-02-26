local PropsTypes = require(script.Parent.Misc.PropertyTypes)
local Types = require(script.Parent.Types)
local mt = {
    __type = script.Name;
};
mt.__index = mt;

local tins = table.insert
local tf = table.find
local tr = table.remove
local tc = table.clear

function mt:Destroy()
    if self.Thread ~= nil then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local pos = tf(self.Thread,self)
            if pos ~= nil then
                tr(self.Thread,pos);
            end
        end
        self.Thread = nil;
    end
    self.Time = nil;
    self.ToCompile = nil;
    tc(self)
    setmetatable(self,nil);
end
function mt:From(Props: PropsTypes.Property)
    self.Init = Props;
    return self;
end
return function(Time: number,Props: PropsTypes.Property,Thread: Types.Thread)
    if Time == nil or Props == nil then warn(`Time or properties is missing - {debug.traceback()}`); return end;
    local new = setmetatable({
        Time = Time;
        ToCompile = Props;
        Thread = Thread;
    },mt);

    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new;
end
