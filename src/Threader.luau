--[=[
    @class Thread
    Threads help us contain/clean our components.
    ```lua
    local Threader = require(Faye.Threader)
    
    local Thread = Threader();
    ```
    You will most likely use this for all of your components as it wraps the **Faye** features and automatically add them to the cleaner to be cleaned when it's necessary.

]=]
local mt = {};
mt.__index = mt;
local tins,tf,tr = table.insert,table.find,table.remove
--types
local Types = require(script.Parent.Types);

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
    local new = {};
    setmetatable(new,mt);
    if NoAttachment ~= true then
        table.insert(self,new);
    end
    return new :: typeof(self);
end

--[=[
    @within Thread
    @method Clean
    This method cleans everything added to the thread, and the thread itself. After this method gets called the thread is no longer useable.
]=]
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
function mt:Animate(Goal: any, Info: Types.Info | Types.SpringInfo)
    return Animate(Goal,Info,self);
end

--TweenInfo
local Info = require(Utilities.Info)
function mt:Info(Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number)
   return Info(Time,EasingStyle,EasingDirection,RepeatCount,Reverse,DelayTime)
end
--SpringInfo
local Spring = require(Utilities.SpringInfo)
function mt:SpringInfo(Time: number,Frequency: number,Damping: number, RepeatCount: number,Reverse: boolean,DelayTime: number)
    return Spring(Time,Frequency,Damping,RepeatCount,Reverse,DelayTime)
end

--connect
function mt:Connect(Connection: RBXScriptSignal,Function: () -> ())
    tins(self,Connection:Connect(Function))
end
--[=[
    @within Thread
    @method Add
    @param Entity any --The entity to add to the thread
]=]
function mt:Add(Entity: any)
    if Entity == nil then return end;
    tins(self,Entity)
end
--[=[
    @within Thread
    @method Remove
    @param Entity any --The entity to remove from the thread, meaning when the thread is cleaned it won't be cleaned with it.
]=]
function mt:Remove(Entity: any)
    if Entity == nil then return end;
    local find = tf(self,Entity)
    if find ~= nil then
        tr(self,find)
    end
end
--Do
local Do = require(Utilities.Do)
function mt:Do(Function: (Grab: any, Entity: Instance) -> ())
    return Do(Function,self)
end
--State
local State = require(Utilities.State)
function mt:State(Function: (Grab: any, InnerThread: Types.Thread,Entity: Instance) -> ())
    return State(Function,self)
end
--Iterate
local Iterate = require(Utilities.Iterate)
function mt:Iterate(Table: any, Function: (Index: any,Value: any,InnerThread: Types.Thread?,Entity: Instance?) -> ())
    return Iterate(Table,Function,self)
end
--Delay value
local Delay = require(Utilities.Delay)
function mt:Delay(Value: Types.Value, Time: number)
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
function mt:SetTo(Value: Types.Value)
    return SetTo(Value,self)
end

--Event
local Eventt = require(Utilities.Event)
function mt:Event(Entity: any, Event: any, Function: () -> ()) : ()
    return Eventt(Entity,Event,Function,self)
end

local scriptName = script.Name;
function mt.__tostring()
    return scriptName;
end
return function() : Types.Thread
    local new = {}
    setmetatable(new,mt)
    return new :: any;
end
