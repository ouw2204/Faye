--[=[
    @class Animate
    A class that handles animations.
]=]

local tc,tf,tr,tof = table.clear,table.find,table.remove,typeof
local OtherTypes = require(script.Parent.Types)
local mt = {
    __type = script.Name;
}
mt.__index = mt;
local Functions = require(script.Functions)
local Cleaner = require(script.Parent.Clean)
--math
max = math.max
local AnimsHandler = require(script.AnimsPlayer);

--[=[
    @method UpdateInfo
    @within Animate
    @param Info OtherTypes.Info
    Updates the animation information.
]=]
function mt:UpdateInfo(Info)
    if Info == nil then return end;
    if Info.__typeIndex == 1 then
        self.Function = Functions[Info.EasingStyle.Name][Info.EasingDirection.Name]
    else
        self.Function = nil;
    end
    self.__typeIndex = Info.__typeIndex;
    self.__Time = Info.Time;
    self.__Reverse = Info.Reverse;
    self.__DelayTime = Info.DelayTime;
    self.__Frequency = Info.Frequency
    self.__Damping = Info.Damping
    self.__RepeatCount = Info.RepeatCount
end

--[=[
    @method Destroy
    @within Animate
    @param FromStop boolean?
    Destroys the animation.
]=]
function mt:Destroy(FromStop)
    if FromStop ==nil then
        self:Stop(true);
    end
    if (self.Thread ~= nil and self.Thread.CleanWhenDone and FromStop == nil) then return end;
    if self.Thread then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local Pos = tf(self.Thread,self)
            if Pos then
                tr(self.Thread,Pos)
            end
        end
        if FromStop == nil then
            self.Thread = nil;
        end
    end

    self.__Time = nil;
    self.__Reverse = nil;
    self.__DelayTime = nil;
    self.__Frequency = nil;
    self.__Damping = nil;
    self.__RepeatCount = nil;

    self.Goal = nil;
    self.Entity = nil;
    self.Property = nil;
    self.Initial = nil;
    self.DontResetInitial = nil;
    self.Function = nil;
    self.__typeIndex = nil;
    self.Elapsed = nil;
    self.SkipToGoal = nil;
    if FromStop == nil then
        tc(self)
    end
    setmetatable(self,nil)
end

--[=[
    @method Stop
    @within Animate
    @param FromDestroy boolean?
    Stops the animation.
]=]
function mt:Stop(FromDestroy)
    if self.Thread ~= nil then
        if self.Thread.AnimationsAmount ~= nil and AnimsHandler:Remove(self) == true then
            self.Thread.AnimationsAmount = math.max(self.Thread.AnimationsAmount - 1, 0)
        end
        if self.Thread.CleanWhenDone and (self.Thread.AnimationsAmount ~= nil and self.Thread.AnimationsAmount <= 0) then
            self.Thread.CleanWhenDone = nil;
            if FromDestroy == nil then
                self:Destroy(true)
            end
            if self.Thread ~= nil then
                Cleaner(self.Thread)
            end
        end
    end
    self.Elapsed = nil;
end

--[=[
    @method Skip
    @within Animate
    Skips to the goal of the animation.
    @return Animation
]=]
function mt:Skip()
    if self.Goal == nil or tof(self.Goal) == "table" then return self end;
    self.SkipToGoal = true;
    return self;
end

--[=[
    @method Play
    @within Animate
    @param To any
    @param T any?
    Plays the animation.
]=]
function mt:Play(To: any,T)
   if To == nil then return end;
   if (self.Thread ~= nil and self.Thread.CleanWhenDone) and not (self.Thread ~= nil and self.Thread.CleanWhenDone == true and self.Thread.AnimationsAmount ~= nil and self.Thread.AnimationsAmount >0) then return end;
   self:Stop();
   if self.Entity == nil or self.Property == nil then warn(`Entity or property is missing - {debug.traceback()}`); return end;
   if self.Thread ~= nil then
        self.Thread.AnimationsAmount = (self.Thread.AnimationsAmount or 0) + 1
    end
    self.__To = To;
    AnimsHandler:Add(self);
end

--[=[
    @method From
    @within Animate
    @param Value any
    Sets the initial value of the animation.
    @return Animation
]=]
function mt:From(Value: any)
    if Value == nil then warn(`Must pass a from value - {debug.traceback()}`); return end;
    self.Initial = Value;
    return self;
end

--[=[
    @method AlwaysFrom
    @within Animate
    @param Value any
    Sets the initial value of the animation and prevents it from being reset.
    @return Animation
]=]
function mt:AlwaysFrom(Value: any)
    if Value == nil then warn(`Must pass a from value - {debug.traceback()}`); return end;
    self.Initial = Value;
    self.DontResetInitial = true;
    return self;
end
--[[
mt.__tostring = function(tab)
    if tab.Property ~= nil and tab.Entity ~= nil then
        return `Anim[{tab.Entity.Name}: {tab.Property}]`
    end
    return "Anim[Unknown: Unknown]"
end]]

--[=[
    @function Animation
    @within Animate
    @param Goal any
    @param Info OtherTypes.Info | OtherTypes.SpringInfo
    @param Thread OtherTypes.Thread?
    @return Animation
    Creates a new animation object.
]=]
return function(Goal: any,Info: OtherTypes.Info | OtherTypes.SpringInfo,Thread: OtherTypes.Thread?) : OtherTypes.AnimationType
    local new = {
        Goal = Goal;
        Thread = Thread;
        Entity = nil;
        Property = nil;
        Info = Info;
    }
    setmetatable(new,mt)
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            table.insert(Thread,new)
        end
    end
    return new :: any;
end
