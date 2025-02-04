local mt = {};
mt.__index = mt;

local Misc = script.Parent:WaitForChild("Misc")
--types
local OtherTypes = require(Misc.OtherTypes);

--utils
local Utilities = script.Parent;

--methods
local Create = require(script.Parent.Create)
function mt:Create(ClassName: string)
    return Create(ClassName,self)
end
--Configure
local Configure = require(script.Parent.Configure)
function mt:Configure(Entity: any)
    return Configure(Entity,self)
end
--thread extension
function mt:Extend(NoAttachment) : {}
    local new = setmetatable({},mt);
    if NoAttachment ~= true then
        table.insert(self,new);
    end
    return new :: typeof(self);
end

--clean
local Clean = require(script.Parent.Clean)
function mt:Clean() : ()
    Clean(self)
end

--Value
local Value = require(Utilities.Value);
function mt:Value(Initial: any)
    return Value(Initial,self)
end

--Animate
local Animate = require(Utilities.Animate)
function mt:Animate(Goal: any, Info: OtherTypes.Info | OtherTypes.SpringInfo)
    return Animate(Goal,Info,self);
end

--TweenInfo
local Info = require(Utilities.Info)
function mt:Info(Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number)
   return Info(Time,EasingStyle,EasingDirection,RepeatCount,Reverse,DelayTime,self)
end
--SpringInfo
local Spring = require(Utilities.SpringInfo)
function mt:SpringInfo(Time: number,Frequency: number,Damping: number, RepeatCount: number,Reverse: boolean,DelayTime: number)
    return Spring(Time,Frequency,Damping,RepeatCount,Reverse,DelayTime,self)
end

--connect
function mt:Connect(Connection: RBXScriptSignal,Function: () -> ())
    table.insert(self,Connection:Connect(Function))
end

--Do
local Do = require(Utilities.Do)
function mt:Do(Function: (Grab: any) -> ())
    return Do(Function,self)
end
--Iterate
local Iterate = require(Utilities.Iterate)
function mt:Iterate(Table: any, Function: (Index: any,Value: any,InnerThread: OtherTypes.ThreaderType?,Entity: Instance?) -> ())
    return Iterate(Table,Function,self)
end
--Delay value
local Delay = require(Utilities.Delay)
function mt:Delay(Value: OtherTypes.Value, Time: number)
    return Delay(Value,Time,self)
end

--Property value
local Propertyy = require(Utilities.Property)
function mt:Property(Instance: any,Property: string)
    return Propertyy(Instance,Property,false,self);
end
--Attribute
function mt:Attribute(Instance: any,Property: string)
    return Propertyy(Instance,Property,true,self);
end

--SetTo
local SetTo = require(Utilities.SetTo)
function mt:SetTo(Value: OtherTypes.Value)
    return SetTo(Value,self)
end

--Event
local Eventt = require(Utilities.Event)
function mt:Event(Entity: any, Event: any, Function: () -> ()) : ()
    return Eventt(Entity,Event,Function,self)
end
return function() : OtherTypes.ThreaderType
    local new = {}
    setmetatable(new,mt)
    return new :: any;
end
