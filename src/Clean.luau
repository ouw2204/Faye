local tof,tc = typeof,table.clear
local destroytxt,tabletxt,cleantxt,instancetxt,functiontxt,rbxlscripttxt,threadtxt = "Destroy","table","Clean","Instance","function","RBXScriptConnection","thread"
function Recursive(Scope,Count: number?)
	if Scope == nil then
		return
	end
	do
		Scope.__Destroying = true;
		Scope.ParentThread = nil
		if Scope.ConnectionsHolder ~= nil then
			for i = #Scope.ConnectionsHolder,1,-1 do
				Scope.ConnectionsHolder[i]:Disconnect();
				Scope.ConnectionsHolder[i] = nil;
			end
			Scope.ConnectionsHolder = nil;
		end
		-- add connection thing
		Scope._isCleanAncestor = nil
		Scope.CleanWhenDone = nil
		Scope.IsActive = nil;
		Scope.Cleaning = nil
		Scope._hc = nil;
		for k = Count or #Scope, 1, -1 do
			local v = Scope[k]
			local type = tof(v)
			Scope[k] = nil
			if type == tabletxt then
				if v[destroytxt] ~= nil or v[cleantxt] ~= nil then
					if v.__Destroying then Scope[k] = nil; continue end;
					if v[destroytxt] then
						v:Destroy()
					elseif v[cleantxt] then
						v:Clean()
					end
				else
					tc(v)
				end
			elseif type == instancetxt then
				v:Destroy()
			elseif type == functiontxt then
				v()
			elseif type == rbxlscripttxt then
				v:Disconnect()
			elseif type == threadtxt then
				task.cancel(v)
			end
		end
		Scope.AnimationsAmount = nil
		Scope.__Destroying = nil;
		setmetatable(Scope, nil)
	end
end
return function(Scope)
	Recursive(Scope)
end
