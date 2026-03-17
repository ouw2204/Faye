local CleanPortion = require(script.Parent.Misc.CleanPortion)
function Recursive(Scope,Count: number?)
	if Scope == nil then
		return
	end
	do
		Scope.__Destroying = true;
		Scope.ParentThread = nil
		
		Scope._isCleanAncestor = nil
		Scope.CleanWhenDone = nil
		Scope.IsActive = nil;
		Scope.Cleaning = nil
		Scope._hc = nil;

		-- clean priority
		if Scope.Priority ~= nil then
			CleanPortion(Scope.Priority)
			Scope.Priority = nil;
		end
		CleanPortion(Scope,Count)
		Scope.AnimationsAmount = nil
		Scope.__Destroying = nil;
	end
end
return function(Scope)
	Recursive(Scope)
end
