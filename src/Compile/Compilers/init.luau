local tins, tf, tr = table.insert, table.find, table.remove
local tof = typeof
local tc = table.clear
local repeatedCompile = require(script.repeatedCompile)
local Utility = require(script.Parent.Parent.Misc.Utility)
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
	Signal = require(script.CompileSignal),

	Iterate = require(script.CompileIterate),

	--<Do/State
	State = require(script.CompileState); -- covers both Do and State
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
