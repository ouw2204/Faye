local Types = require(script.Parent.Types)
local mt = {
    __type = script.Name;
};
mt.__index = mt;

local tins = table.insert
local tf = table.find
local tr = table.remove
local tc = table.clear

--[=[
    @class Delay
    A class that represents a delay with properties and threading.
]=]

--[=[
    @method Destroy
    @within Delay
    Destroys the delay object and cleans up its resources.
]=]
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

--[=[
    @method From
    @within Delay
    @param Props Types.Properties
    Initializes the delay object with the given properties.
    @return Delay
]=]
function mt:From(Props: Types.Properties)
    self.Init = Props;
    return self;
end

--[=[
    @method Delay
    @within Thread
    @param Time number
    @param Props Types.Properties
    @param Thread Types.Thread
    @return Delay
    Creates a new delay object.
]=]
return function(Props: Types.Properties,Time: number,Thread: Types.Thread)
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
