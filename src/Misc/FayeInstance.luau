local ValueClasses = require(script.Parent.Parent.Misc.ValueClasses)
local Compilers = require(script.Parent.Parent.Compile.Compilers)
local Compile = require(script.Parent.Parent.Compile)
local Clean = require(script.Parent.Parent.Clean)
local Types = require(script.Parent.Parent.Types)
local tof = typeof
local tr = table.remove
local tins = table.insert
local tf = table.find
local Utility = require(script.Parent.Parent.Misc.Utility)
local mt = { __type = "Instance" }
mt.__index = mt

local tc = table.clear
function removefunc(t: Types.Thread, v: any)
	if t == nil or v == nil then
		return
	end
	if t["Remove"] then
		return t:Remove(v)
	else
		local pos = tf(t, v)
		if pos ~= nil then
			tr(t, pos)
		end
	end
	return false
end
--[=[
    @method SetAttribute
    @within Create
    @param Attribute string
    @param Value any
    @return Create
    Similar to SetAttribute method for roblox instances
]=]
function mt:SetAttribute(Attribute: string, Value: any)
	if self.Instance ~= nil then
		self.Instance:SetAttribute(Attribute,Value)
	end
	return self;
end
--[=[
    @method GetAttribute
    @within Create
    @param Attribute string
    @return Value
    Similar to the GetAttribute method for roblox instances
]=]
function mt:GetAttribute(Attribute: string)
	if self.Instance ~= nil then
		return self.Instance:GetAttribute(Attribute)
	end
end
--[=[
    @method GetAttributes
    @within Create
    Similar to the GetAttributes method for roblox instances
]=]
function mt:GetAttributes(Attribute: string)
	if self.Instance ~= nil then
		return self.Instance:GetAttributes()
	end
end

--[=[
    @method AddTag
    @within Create
    @param Tag string
    Similar to the AddTag method for roblox instances
]=]
function mt:AddTag(Tag: string)
	if self.Instance ~= nil then
		self.Instance:AddTag(Tag)
	end
	return self;
end
--[=[
    @method RemoveTag
    @within Create
    @param Tag string
    Similar to the RemoveTag method for roblox instances
]=]
function mt:RemoveTag(Tag: string)
	if self.Instance ~= nil then
		self.Instance:RemoveTag(Tag)
	end
	return self;
end
--[=[
    @method HasTag
    @within Create
    @param Tag string
    Similar to the HasTag method for roblox instances
]=]
function mt:HasTag(Tag: string)
	if self.Instance ~= nil then
		return self.Instance:HasTag(Tag)
	end
end
--[=[
    @method GetTags
    @within Create
    Similar to the GetTags method for roblox instances
]=]
function mt:GetTags()
	if self.Instance ~= nil then
		return self.Instance:GetTags()
	end
end

--[=[
    @method Compile
    @within Create
    Compiles the properties of the instance.
]=]
function mt:Compile()
	local Props = self.Props
	if Props ~= nil then
		local AddClean = nil
		local ThreadUsing = self.InnerThread or self.Thread;
		local PropsOrCleanCheck = Props.CleanDelay ~= nil or Props.OnClean ~= nil
		if (ThreadUsing._hc or ThreadUsing._isCleanAncestor) and PropsOrCleanCheck and self.InnerThread ~= nil and self.InnerThread._isCleanAncestor and ThreadUsing.ParentThread ~= nil then
			if Props.CleanFunction == nil and Props.OnClean ~= nil then
				AddClean = true;
				Props.CleanFunction = Props.OnClean
			end
			Props.CleanDelay = nil;
			Props.OnClean = nil;
		else
			
			if PropsOrCleanCheck then
				if self.Thread ~= nil then
					self.Thread._hc = true --hc = hasclean
					self.Thread._isCleanAncestor = true
				end
				if self.InnerThread == nil then
					self.InnerThread = (self.Thread ~= nil and self.Thread:Extend(true)) or {}
					self.InnerThread._isCleanAncestor = true
				end

				if Props.CleanDelay ~= nil then
					self.CleanDelay = Props.CleanDelay
					Props.CleanDelay = nil
				end
				if Props.OnClean ~= nil then
					self.OnClean = Props.OnClean
					Props.OnClean = nil
				end
				if Props.CleanFunction ~= nil then
					AddClean = true
				end
			else
				if Props.CleanFunction ~= nil then
					AddClean = true
				end
			end
		end

		PropsOrCleanCheck = nil;
		ThreadUsing = nil;
		if AddClean == true then
			if self.Thread ~= nil and self.Thread._isCleanAncestor then
				local f = Props.CleanFunction
				self.cf = function()
					if f == nil then
						return
					end
					f(self.InnerThread or self.Thread, self.Instance)
					removefunc(self.connected,self.cf)
					f = nil
					self.cf = nil
					self.connected = nil;
				end
				local eq = self.Thread
				if eq.ParentThread ~= nil then
					local current = eq
					while current ~= nil do
						if current._hc then
							break
						end
						current = current.ParentThread
					end
					eq = current or eq;
				end
				eq:Add(self.cf)
				self.connected = eq;
			else
				self.CleanFunction = Props.CleanFunction
			end
		end
		AddClean = nil
		Props.CleanFunction = nil
		Props.CleanDelay = nil
		if Props.Parent ~= nil then
			local Parent = Props.Parent
			Props.Parent = nil
			local eqistable = typeof(Parent) == "table"
			local EqType = (
				eqistable and (Parent.__type ~= nil and ((ValueClasses[Parent.__type] and "Value") or Parent.__type))
			) or nil
			if EqType ~= nil and EqType ~= "Instance" then
				Compilers[EqType](self, "Parent", Parent)
			else
				if eqistable then
					self.Instance.Parent = Parent.Instance or Parent
				else
					self.Instance.Parent = Parent
				end
			end
		end
		self.Props = nil
		Compile(self, Props)
	else
		self:Destroy()
	end
end

--[=[
    @method Destroy
    @within Create
    Destroys the instance.
]=]
function mt:Destroy()
	if self.Thread ~= nil then
		if self.Thread["Remove"] then
			self.Thread:Remove(self)
		else
			local Find = tf(self.Thread, self)
			if Find ~= nil then
				tr(self.Thread, Find)
			end
		end
	end

	--< remove all clean incase they are no yields so they aren't any errors
	if self.connected ~= nil then
		if self.Thread ~= self.connected then
			Utility.RemoveFromThread(self.Thread,self.cf)
		end;
		removefunc(self.connected, self.cf)
		self.connected = nil;
		self.cf = nil;
	end
	-->

	if self.CleanFunction ~= nil then
		self.CleanFunction(self.InnerThread or self.Thread, self.Instance)
		self.CleanFunction = nil
	end
	if self.OnClean ~= nil then
		if self.InnerThread["Add"] then
			self.InnerThread:Add(self.Instance)
		else
			table.insert(self.InnerThread, self.Instance)
		end

		self.OnClean(self.InnerThread, self.Instance)
		if self.InnerThread ~= nil then
			if self.InnerThread.AnimationsAmount == nil or self.InnerThread.AnimationsAmount <= 0 then
				Clean(self.InnerThread)
			else
				self.InnerThread.CleanWhenDone = true
			end
			self.InnerThread = nil
		end
		self.Instance = nil
		self.OnClean = nil
	else
		if self.CleanDelay ~= nil then
			local delaytime = self.CleanDelay
			if tof(delaytime) == "function" then
				delaytime = delaytime(self.InnerThread,self.Instance)
			end
			task.delay(delaytime, function()
				self.Instance:Destroy()
				self.Instance = nil
				Clean(self.InnerThread)
				self.CleanFunction = nil
				self.OnClean = nil
				self.InnerThread = nil
				tc(self)
			end)
			self.CleanDelay = nil
		else
			self.Instance:Destroy()
			self.Instance = nil
			self.CleanFunction = nil
			self.OnClean = nil
			self.InnerThread = nil
			tc(self)
		end
	end
	self.CleanDelay = nil
	self.Props = nil
	self.Thread = nil
	setmetatable(self, nil)
end
--[[
local scriptName = script.Name
function mt.__tostring()
	return scriptName
end]]
return mt