local Utility = require(script.Parent.Utility);
local Types = require(script.Parent.Parent.Types)
local Compile = require(script.Parent.Parent.Compile)
return function (res1: any,res2: any,Entity: Types.FayeInstance, Thread: Types.Thread)
	local NewCompile
	if res2 == nil and res1 ~= nil then
		NewCompile = (Utility.tof(res1) == Utility.tabletxt and res1.__type == nil and res1) or {res1}
	elseif res1 ~= nil and res2 ~= nil then
		NewCompile = {[res1] = res2}
	end
	if NewCompile ~= nil then
		Compile(Entity, NewCompile, Thread or (Entity.InnerThread or Entity.Thread) )
	end;

	NewCompile = nil;
end