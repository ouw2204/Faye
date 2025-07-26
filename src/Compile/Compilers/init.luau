local tins, tf, tr = table.insert, table.find, table.remove
local tof = typeof
local tc = table.clear
local repeatedCompile = require(script.repeatedCompile)
local m = {
	SetTo = function(Entity, Index, Value)
		if Value["Value"] ~= nil and Value.Value["Set"] ~= nil then
			Value.Value:Set(Entity)
		end
		Value:Destroy()
	end,
	Spawn = function(Entity, Index, Value, Compile)
		Value:Perform(Entity, Index, Compile, Value.Thread or (Entity.InnerThread or Entity.Thread))
	end,
	Instance = function(Entity, Index, Value, Compile, From)
		local Props = Value.Props
		local Thread = Entity.Thread
		local InnerThread = Entity.InnerThread
		if Props ~= nil then
			--#thu 17 2025
			if InnerThread ~= nil and InnerThread ~= Thread and ((Value.Props.OnClean == nil and Value.Props.CleanDelay == nil) or InnerThread._isCleanAncestor) then
				if Thread["Remove"] then
					Thread:Remove(Value)
				else
					local pos = tf(Thread, Value)
					if pos ~= nil then
						tr(Thread, pos)
					end
				end
				if InnerThread["Add"] then
					InnerThread:Add(Value)
				else
					tins(InnerThread, Value)
				end
				Value.InnerThread = InnerThread
			end
			if Props.Parent == nil then
				Props.Parent = Entity.Instance
			end
			Value:Compile()
		end
	end,
	OnChanged = function(Entity, Index, Value, Compile, Init)
		local Instance = Entity.Instance
		local Thread = Entity.InnerThread or Entity.Thread
		if Init == true then
			local Ret = Value(Instance, Instance[Index])
			if Ret ~= nil then
				repeatedCompile(Index, Thread, Ret, Compile, Entity)
				Ret = nil
			end
		end
		Thread:Connect(Instance:GetPropertyChangedSignal(Index), function()
			local Ret = Value(Instance, Instance[Index])
			if Ret ~= nil then
				repeatedCompile(Index, Thread, Ret, Compile, Entity)
				Ret = nil
			end
		end)
	end,
	MethodSignaled = require(script.MethodSignaled);
	EventCompiler = function(Entity, Index, Value, Compile)
		local Instance = Entity.Instance
		local Thread = Entity.InnerThread or Entity.Thread -- fetching innerthread or thread with priority
		if Thread ~= nil then -- thread exist
			if Thread["Connect"] ~= nil then
				Thread:Connect(Instance[Index], function(...)
					local Ret = Value(Instance, ...)
					if Ret ~= nil then
						repeatedCompile(Index, Thread, Ret, Compile, Entity)
						Ret = nil
					end
				end)
			elseif Thread["Add"] ~= nil then -- is a specialized cleaner
				Thread:Add(
					Instance[Index]:Connect(function(...)
						local Ret = Value(Instance, ...)
						if Ret ~= nil then
							repeatedCompile(Index, Thread, Ret, Compile, Entity)
							Ret = nil
						end
					end),
					true
				)
			else
				tins(
					Thread,
					Instance[Index]:Connect(function(...)
						local Ret = Value(Instance, ...)
						if Ret ~= nil then
							repeatedCompile(Index, Thread, Ret, Compile, Entity)
							Ret = nil
						end
					end)
				)
			end
		else -- no threads
			Instance[Index]:Connect(function(...)
				local Ret = Value(Instance, ...)
				if Ret ~= nil then
					repeatedCompile(Index, Thread, Ret, Compile, Entity)
					Ret = nil
				end
			end)
		end

		--Thread = nil;
	end,
	Event = function(Entity, Index, Value)
		local Thread = Entity.InnerThread or Entity.Thread
		if Value.__Thread ~= Thread then
			if Value.__Thread ~= nil then
				if Value.__Thread["Remove"] then
					Value.__Thread:Remove(Value)
				else
					local f = tf(Value.__Thread, Value)
					if f ~= nil then
						tr(Value.__Thread, f)
					end
				end

				if Value.__currentcleaner ~= nil then
					if Value.__Thread["Remove"] then
						Value.__Thread:Remove(Value.__currentcleaner)
					else
						local pos = tf(Value.__Thread, Value.__currentcleaner)
						if pos ~= nil then
							tr(Value.__Thread, pos)
						end
					end
					if Thread["Add"] then
						Thread:Add(Value.__currentcleaner)
					else
						tins(Thread, Value.__currentcleaner)
					end
				end
			end
			Value.__Thread = Thread
		end
		Value.__entity = Entity
		if tof(Index) ~= "number" then
			Value.__property = Index
		end
		if Value.__callOnInit then
			task.spawn(function()
				Value.__prefunc(table.unpack(Value.__callOnInit))
			end)
			table.clear(Value.__callOnInit)
			Value.__callOnInit = nil
		end
		Value.__Initiated = true
	end,

	Iterate = require(script.CompileIterate),

	--<Do/State
	Do = function(Entity, Index, Value)
		local Thread = Entity.InnerThread or Entity.Thread
		if Thread ~= nil and Thread ~= Value.Thread then
			if Value.Thread ~= nil then
				if Value.Thread["Remove"] then
					Value.Thread:Remove(Value)
				else
					local f = tf(Value.Thread, Value)
					if f ~= nil then
						tr(Value.Thread, f)
					end
				end
			end
			Value.Thread = Thread
			if Thread["Add"] then
				Thread:Add(Value)
			else
				tins(Thread, Value)
			end
		end
		Value.Entity = Entity
		if tof(Index) ~= "number" then
			Value.Property = Index
		end
		task.spawn(Value.OnValueChanged)
	end,
	State = require(script.CompileState);
	--> Do/State

	Delay = function(Entity, Index, Value, Compile)
		local Init = Value.Init
		local ToCompile = Value.ToCompile
		if Init ~= nil then
			if tof(Init) == "table" then
				Compile(Entity, Init)
				tc(Init)
			else
				Compile(Entity, { [Index] = Init })
			end
			Init = nil
		end
		task.delay(Value.Time, function()
			if Entity ~= nil and Entity.Instance ~= nil then
				if tof(ToCompile) == "table" then
					Compile(Entity, ToCompile)
					tc(ToCompile)
				else
					Compile(Entity, { [Index] = ToCompile })
				end
				ToCompile = nil
			end
		end)
		Value:Destroy()
	end,
	Animation = require(script.CompileAnimations);
	Value = require(script.CompileValue)
}

return m
