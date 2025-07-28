--[=[
    @class Configure
    [Allows configuration on an existing physical or none physical component.](/docs/Instancing/Create) Inherits method from [Create](/api/Create).
]=]
local Types = require(script.Parent.Types)
local ValueClasses = require(script.Parent.Misc.ValueClasses)

local tins = table.insert
local tof = typeof
local mt = require(script.Parent.Misc.FayeInstance)
--[=[
    @method Configure
    @within Thread
    @param Entity any
    @param Thread {Add: (self: {},Entity: any) -> ()}?
    @return function
    [Allows configuration on an existing physical or none physical component.](/docs/Instancing/Create) Inherits method from [Create](/api/Create).
]=]
return function(Entity: any, Thread: { Add: (self: {}, Entity: any) -> () }?)
	return function(props: Types.Properties)
		if tof(Entity) == "table" then
			if Entity.__type == "Instance" then
				Entity = Entity.Instance
			elseif ValueClasses[Entity.__type] then
				Entity = Entity:Get()
				if tof(Entity) == "table" and Entity.__type == "Instance" then
					Entity = Entity.Instance
				end
			end
		end
		if Entity == nil or tof(Entity) ~= "Instance" then
			warn(`Entity must be an instance for configure or a value that gives an instance - {debug.traceback()}`)
			return
		end

		local Simple = true
		if props.Properties ~= nil then
			for i, v in pairs(props.Properties) do
				props[i] = v
			end
			props.Properties = nil
		end
		for i, v in pairs(props) do
			local tov = tof(v)
			if tov ~= "function" and tov ~= "table" and i ~= "CleanDelay" and tov ~= "Instance" then
				Entity[i] = v
				props[i] = nil
			else
				Simple = false
			end
		end

		if Simple then
			return Entity
		else
			local Wrapper = setmetatable({
				Instance = Entity,
				Props = props,
				Thread = Thread,
			},mt)
			Wrapper:Compile()
			if Thread ~= nil then
				if Thread["Add"] then
					Thread:Add(Wrapper)
				else
					tins(Thread, Wrapper)
				end
			end
			return Wrapper
		end
	end
end
