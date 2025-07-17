--[=[
    @class Animate
    A class that handles animations.
]=]

local tc, tf, tr,tof = table.clear, table.find, table.remove,typeof
local OtherTypes = require(script.Parent.Types)
local mt = {
	__type = script.Name,
}
mt.__index = mt

local Cleaner = require(script.Parent.Clean)

local Helper = require(script.Helper)

--[=[
    @method UpdateInfo
    @within Animate
    @param Info OtherTypes.Info
    Updates the animation information.
]=]
local defaultdirection = Enum.EasingDirection.Out;
local defaultstyle = Enum.EasingStyle.Linear;
function mt:UpdateInfo(Info)
	if Info == nil then
		warn(`Info was not passed - {debug.traceback()}`)
		return self
	end
	local HasOneInfo =  Info.__typeIndex == 1 or Info.EasingStyle ~= nil or Info.EasingDirection ~= nil
	local HasOneSpringInfo = Info.__typeIndex == 2 or Info.Damping ~= nil or Info.Frequency ~= nil
	if HasOneInfo and not HasOneSpringInfo and self.__typeIndex ~= 1 then
		self.__typeIndex = 1;
		if self.__easingdirection == nil and Info.EasingDirection == nil then
			self.__easingdirection = defaultdirection
		end
		if self.__easingstyle == nil and Info.EasingStyle == nil then
			self.__easingstyle = defaultstyle
		end
	elseif not HasOneInfo and HasOneSpringInfo and self.__typeIndex ~= 2 then
		self.__typeIndex = 2
		if self.__Damping == nil and Info.Damping == nil then
			self.__Damping = .2;
		end
		if self.__Frequency == nil and Info.Frequency == nil then
			self.__Frequency = 1;
		end
	end
	self.__easingdirection = Info.EasingDirection or self.__easingdirection
	self.__easingstyle = Info.EasingStyle or self.__easingstyle
	self.__typeIndex = Info.__typeIndex or self.__typeIndex
	self.__Time = Info.Time or self.__Time
	self.__Reverse = Info.Reverse or self.__Reverse
	self.__DelayTime = Info.DelayTime or self.__DelayTime
	self.__Frequency = Info.Frequency or self.__Frequency
	self.__Damping = Info.Damping or self.__Damping
	self.__RepeatCount = Info.RepeatCount or self.__RepeatCount
	return self
end
--[=[
    @method OnetimeInfo
    @within Animate
    @param Info OtherTypes.Info
    Updates the animation information for one play sess.
]=]
function mt:OneTimeInfo(Info)
	if Info == nil then
		return self
	end
	self.__onetimeinfo = Info
	return self
end

--[=[
    @method Destroy
    @within Animate
    @param FromStop boolean?
    Destroys the animation.
]=]
function mt:Destroy(FromStop)
	if self.__cleanFunction ~= nil then
		self.__cleanFunction()
	end --!!
	if FromStop == nil then
		self:Stop(true)
	end
	if self.Thread ~= nil and self.Thread.CleanWhenDone and FromStop == nil then
		return
	end
	if self.Thread then
		if self.Thread["Remove"] then
			self.Thread:Remove(self)
		else
			local Pos = tf(self.Thread, self)
			if Pos then
				tr(self.Thread, Pos)
			end
		end
		if FromStop == nil then
			self.Thread = nil
		end
	end
	self.__Time = nil
	self.__Reverse = nil
	self.__DelayTime = nil
	self.__Frequency = nil
	self.__Damping = nil
	self.__RepeatCount = nil
	self.AnimationsAmount = nil;
	self.__cleanFunction = nil
	self.Goal = nil
	self.Compiled = nil;
	self.Entity = nil
	self.Property = nil
	self.Initial = nil
	self.DontResetInitial = nil
	self.Function = nil
	self.__typeIndex = nil
	self.SkipToGoal = nil
	if FromStop == nil then
		tc(self)
	end
	setmetatable(self, nil)
end

--[=[
    @method Stop
    @within Animate
    @param FromDestroy boolean?
    Stops the animation.
]=]
function mt:Stop(FromDestroy)
	local hasAnim = self.__Anim ~= nil;
	if self.Thread ~= nil then
		if self.Thread.AnimationsAmount ~= nil and Helper.Remove(self) == true then
			self.Thread.AnimationsAmount = math.max(self.Thread.AnimationsAmount - 1, 0)
		end
		if self.Thread.CleanWhenDone and (self.Thread.AnimationsAmount ~= nil and self.Thread.AnimationsAmount <= 0) then
			self.Thread.AnimationsAmount = nil
			self.Thread.CleanWhenDone = nil
			if FromDestroy == nil then
				self:Destroy(true)
			end
			if self.Thread ~= nil then
				Cleaner(self.Thread)
			end
		else
			if self.Thread.AnimationsAmount ~= nil and self.Thread.AnimationsAmount <= 0 then
				self.Thread.AnimationsAmount = nil
			end
		end
	else
		Helper.Remove(self)
	end
	if hasAnim then
		if self.__onetimeinfo ~= nil and self.__cleantempinfo then
			self.__onetimeinfo = nil
		end
	end
end

--[[
    @method Skip
    @within Animate
    Skips to the goal of the animation.
    @return Animation
]]
--[[
function mt:Skip()
    if self.Goal == nil or tof(self.Goal) == "table" then return self end;
    self.SkipToGoal = true;
    return self;
end
]]
--[=[
    @method Play
    @within Animate
    @param To any
    Plays the animation.
]=]
function mt:Play(To: any, Entity: Instance, Property: string,Default: any, DefaultProp: string)
	if To == nil then
		return
	end
	if
		(self.Thread ~= nil and self.Thread.CleanWhenDone)
		and not (
			self.Thread ~= nil
			and self.Thread.CleanWhenDone == true
			and self.Thread.AnimationsAmount ~= nil
			and self.Thread.AnimationsAmount > 0
		)
	then
		return
	end
	self:Stop()
	--[[if self.Entity == nil or self.Property == nil then
		warn(`Entity or property is missing - {debug.traceback()}`)
		return
	end]]
	if self.Thread ~= nil then
		self.Thread.AnimationsAmount = (self.Thread.AnimationsAmount or 0) + 1
	end
	Helper.Add(self,To,Entity,Property,Default,DefaultProp)
end

--[=[
    @method From
    @within Animate
    @param Value any
    Sets the initial value of the animation.
    @return Animation
]=]
function mt:From(Value: any)
	if Value == nil then
		warn(`Must pass a from value - {debug.traceback()}`)
		return self
	end
	self.Initial = Value
	return self
end

--[=[
    @method AlwaysFrom
    @within Animate
    @param Value any
    Sets the initial value of the animation and prevents it from being reset.
    @return Animation
]=]
function mt:AlwaysFrom(Value: any)
	if Value == nil then
		warn(`Must pass a from value - {debug.traceback()}`)
		return self
	end
	self.Initial = Value
	self.DontResetInitial = true
	return self
end


local scriptname = script.Name;
mt.__tostring = function(tab)
    return scriptname
end

--[=[
    @function Animation
    @within Animate
    @param Goal any
    @param Info OtherTypes.Info | OtherTypes.SpringInfo
    @param Thread OtherTypes.Thread?
    @return Animation
    Creates a new animation object.
]=]
local InfoCreater = require(script.Parent.Info)
local DefaultInfo = InfoCreater();
local Utility = require(script.Parent.Misc.Utility)
return function(
	Goal: any,
	Info: OtherTypes.Info | OtherTypes.SpringInfo,
	Thread: OtherTypes.Thread?
): OtherTypes.Animation
	if Goal == nil or Thread == nil then warn("Animaion must be created via thread and must have a goal."); return end;
	local new = {
		Goal = Goal,
		Thread = Thread,
		Info = Info,

		--
		__Anim = nil;
		__easingdirection = nil;
		__Damping = nil;
		__Frequency = nil;
		__easingstyle = nil;
		__typeIndex =  nil;
		__Compiled = false;
		__Time =  nil;
		__Reverse = nil;
		__DelayTime = nil;
		__RepeatCount = nil;
	}
	setmetatable(new, mt)
	if Thread ~= nil then
		if Thread["Add"] then
			Thread:Add(new)
		else
			table.insert(Thread, new)
		end
	end
	new:UpdateInfo(Utility.GetValue(Info) or DefaultInfo)
	return new :: any
end
