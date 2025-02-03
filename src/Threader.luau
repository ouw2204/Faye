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

--thread extension
function mt:Extend() : {}
    local new = setmetatable({},mt);
    table.insert(self,new);
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
return function() : OtherTypes.ThreaderType
    local new = {}
    setmetatable(new,mt)
    return new :: any;
end
