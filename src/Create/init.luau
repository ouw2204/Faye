--[=[
    @class Create
    A class that handles the creation of instances.
]=]
local Types = require(script.Parent.Types)
local Defaults = require(script.Defaults)
local tins = table.insert
local tof = typeof
local mt = require(script.Parent.Misc.FayeInstance)
--[=[
    @method Create
    @within Thread
    @param ClassName string
    @param Thread {Add: (self: {},Entity: any) -> ()}?
    @return (props: PropertyTypes.Property) -> Create
    [Creates a new instance object.](/docs/Instancing/Create)
]=]
return function(ClassName: string, Thread: { Add: (self: {}, Entity: any) -> () }?)
	return function(props: Types.Properties)
		local Object = Instance.new(ClassName)
		if Defaults[ClassName] ~= nil then
			Defaults[ClassName](Object)
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
				Object[i] = v
				props[i] = nil
			else
				Simple = false
			end
		end

		if Simple then
			return Object
		else
			local Wrapper = setmetatable({
				Instance = Object,
				Props = props,
				Thread = Thread,
			},mt)
			if props.Parent then
				Wrapper:Compile()
			end
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
