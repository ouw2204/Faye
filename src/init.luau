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
local destroytxt,tabletxt,cleantxt,instancetxt,functiontxt,rbxlscripttxt,threadtxt = "Destroy","table","Clean","Instance","function","RBXScriptConnection","thread"
--types
local Types = require(script.Types);

--methods
local Create = require(script.Create)
function mt:Create(ClassName: string)
    return Create(ClassName,self)
end
--Configure
local Configure = require(script.Configure)
function mt:Configure(Entity: any)
    return Configure(Entity,self)
end
--thread extension
--[=[
    @within Thread
    @method Extend
    @param NoLink boolean
    @return Thread
    Creates a sub-thread. Leave the NoLink to nil and the thread will be linked to the parent thread(will delete with parent), set NoLink to true for the thread to be independent.
]=]
function mt:Extend(NoAttachment) : Types.Thread
    local new: any = {};
    setmetatable(new,mt);
    if NoAttachment == nil then
        new._isCleanAncestor = self._isCleanAncestor
        table.insert(self,new);
    else
        if self.ConnectionsThread ~= nil then
            new.ConnectionsThread = self.ConnectionsThread
        else
            new.ConnectionsThread = self;
        end
    end
    new.ParentThread = self
    return new;
end
--[=[
    @within Thread
    @method Spawn
    Similar to Task.spawn, not to be used within a compileable table.
]=]
local removetxt = "Remove"
function mt:Spawn(func: (...any) -> (),...)
    if func == nil then return end;
    local task; task = task.spawn(function(...)
        func(...)
        if self[removetxt] ~= nil then
            self:Remove(task)
        end
    end,...)
    self:Add(task)
end
--[=[
    @within Thread
    @method Clean
    This method cleans everything added to the thread, and the thread itself. After this method gets called the thread is no longer useable.
]=]
local Clean = require(script.Clean)
function mt:Destroy() : ()
    if self.ParentThread ~= nil then
        self.ParentThread:Remove(self)
        self.ParentThread = nil;
    end
    Clean(self)
end
--Value
local Value = require(script.Value);
function mt:Value(Initial: any)
    return Value(Initial,self)
end

--Animation
local Animation = require(script.Animation)
function mt:Animation(Goal: any, Info: (Types.Info | Types.SpringInfo)?,Modifications: Types.AnimationModifications?)
    return Animation(Goal,Info,Modifications,self);
end
--| Animation functions
local ModifyAnimation = require(script.ModifyAnimation)
function mt.ModifyAnimation(Animaiton: {any: any},Modifications: Types.AnimationModifications?)
    return ModifyAnimation(Animaiton,Modifications)
end
local CloneAnimation = require(script.CloneAnimation)
function mt:CloneAnimation(Animaiton: {any: any},Modifications: Types.AnimationModifications?)
    return CloneAnimation(Animaiton,Modifications,self)
end
--|

--TweenInfo
local Info = require(script.Info)
function mt.Info(Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number)
   local Ret = Info(Time,EasingStyle,EasingDirection,RepeatCount,Reverse,DelayTime);
   --self:Add(Ret);
   return Ret
end
--SpringInfo
local Spring = require(script.SpringInfo)
function mt.SpringInfo(Time: number,Frequency: number,Damping: number, RepeatCount: number,Reverse: boolean,DelayTime: number)
    local Ret = Spring(Time,Frequency,Damping,RepeatCount,Reverse,DelayTime);
    --self:Add(Ret);
    return Ret
end

--[=[
    @within Thread
    @method Connect
    @param Connection RBXScriptSignal
    @param Function: () -> ()
    Signal connection
]=]
--connect
function mt:Connect(Connection: RBXScriptSignal,Function: () -> ())
    self:Add(Connection:Connect(Function),true)
end
--[=[
    @within Thread
    @method Add
    @param Entity any
    The entity to add to the thread
]=]
local tof = typeof
function mt:Add(Entity: any,IsConnection)
    if Entity == nil then return end;
    if IsConnection and self.ConnectionsThread ~= nil then
        if tof(Entity) == tabletxt and Entity.__simplesignalconnection and Entity.lists == nil then
            Entity.lists = self.ConnectionsThread;
        end
        tins(self.ConnectionsThread,Entity)
    else
        if tof(Entity) == tabletxt and Entity.__simplesignalconnection and Entity.lists == nil then
            Entity.lists = self;
        end
        tins(self,Entity)
    end
end
--[=[
    @within Thread
    @method Remove
    @param Entity any
    The entity to remove from the thread, meaning when the thread is cleaned it won't be cleaned with it.
]=]
function mt:Remove(Entity: any)
    if Entity == nil then return end;
    local find = tf(self,Entity)
    if find ~= nil then
        tr(self,find)
        return true;
    end
    return
end
--Do
local Do = require(script.Do)
function mt:Do(Function: (Grab: any, Entity: Instance) -> ())
    return Do(Function,self)
end
--Do
local Unyielded = require(script.Unyielded)
function mt:Unyielded(func: (...any) -> ())
    return Unyielded(func,self)
end
function mt:DelayUnyielded(Time: number,func: (...any) -> ())
    return Unyielded(func,self,Time)
end
--State
local State = require(script.State)
function mt:State(Function: (Grab: any, InnerThread: Types.Thread,Entity: Instance) -> ())
    return State(Function,self)
end
--Iterate
local Iterate = require(script.Iterate)
function mt:Iterate(Table: any, Function: (Index: any,Value: any,InnerThread: Types.Thread?,Entity: Instance?) -> ())
    return Iterate(Table,Function,self)
end
--Delay value
local DelayValue = require(script.DelayValue)
function mt:DelayValue(Value: Types.Value, Time: number) : Types.DelayValue
    return DelayValue(Value,Time,self)
end
--Delay
local Delay = require(script.Delay)
function mt:Delay(Props: Types.Properties,Time: number) : Types.Delay
    return Delay(Props,Time,self)
end
--Property value
local Propertyy = require(script.Property)
function mt:InstancePropertySync(Instance: Instance,Property: string)
    return Propertyy(Instance,Property,false,self);
end
--Attribute
function mt:InstanceAttributeSync(Instance: Instance,Property: string)
    return Propertyy(Instance,Property,true,self);
end

--SetTo
local SetTo = require(script.SetTo)
function mt:SetTo(Value: Types.Value)
    return SetTo(Value,self)
end
--Listener
local Listener = require(script.Listener)
function mt:Listener(Entity: any, Event: any, Function: () -> ()) : ()
    return Listener(Entity,Event,Function,self)
end
local Space = require(script.Space)
function mt:Space(func: (...any) -> ())
    return Space(func,self);
end
local Signal = require(script.Signal)
function mt:Signal(Connections: RBXScriptSignal | {RBXScriptSignal},func: (...any) -> ()?)
    return Signal(Connections, func,self);
end
local SignalState = require(script.Signal)
function mt:SignalState(Connections: RBXScriptSignal | {RBXScriptSignal},func: (...any) -> ()?)
    return SignalState(Connections, func,self);
end
local MethodSignaled = require(script.MethodSignaled)
function mt:MethodSignaled(Method: string, Index: string)
    return MethodSignaled(Method,Index, self);
end
local PlayAnimation = require(script.PlayAnimation)
function mt:PlayAnimation(Entity: Instance, Property: string,Goal: any, Info: (Types.Info | Types.SpringInfo)?)
    return PlayAnimation(Entity, Property,Goal, Info, self)
end
local tc = table.clear
--[=[
    @within Thread
    @method Schedule
    @param Time number?
    @param Item any
    @param ... any
    @return item
    Cleans an item individually based off the time. can also be used to call functions after a time has passed.
]=]
function  mt:Schedule(Time: number?,Item: any,...)
    if Item == nil then return end;
    local d;
    local func = function(...)
        local type = tof(Item)
        if type == tabletxt then
            if Item[destroytxt] ~= nil or Item[cleantxt] ~= nil then
                if Item[destroytxt] then
                    Item:Destroy()
                elseif Item[cleantxt] then
                    Item:Clean()
                end
            else
                tc(Item)
            end
        elseif type == instancetxt then
            Item:Destroy()
        elseif type == functiontxt then
            Item(...)
        elseif type == rbxlscripttxt then
            Item:Disconnect()
        elseif type == threadtxt then
            task.cancel(Item)
        end
        if d ~= nil then
            self:Remove(d)
            d = nil;
        end;
    end
    
    if Time  ~= nil and Time >0 then
        d = task.delay(Time,func,...)
        self:Add(d)
    else
        task.spawn(Time,func,...)
    end
    return Item;
end
--[[
local scriptName = script.Name;
function mt.__tostring()
    return scriptName;
end]]
return function() : Types.Thread
    local new = {}
    setmetatable(new,mt)
    return new :: any;
end
