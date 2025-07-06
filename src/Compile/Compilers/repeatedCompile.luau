local tof = typeof
local Types = require(script.Parent.Parent.Parent.Types)
local numbertxt,RBXScriptSignaltxt,tabletxt = "number","RBXScriptSignal","table"
return function (Index: number, Thread: Types.Thread, Ret: any, Compile: () -> (), Entity: any)
	if Ret ~= nil then
		if tof(Index) ~= numbertxt and typeof(Entity.Instance[Index]) ~= RBXScriptSignaltxt then
			Entity.Instance[Index] = Ret
		else
			Compile(Entity, (tof(Ret) == tabletxt and Ret.__type == nil and Ret) or { Ret }, Thread)
		end
	end
end