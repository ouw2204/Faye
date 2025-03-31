--add a __isThread = true variable in all your custom threads that don't have a destroy function
local tc = table.clear
function Recursive(Scope,NoDeletion: boolean?)
    if Scope == nil then return end;
    if Scope["Destroy"] ~= nil then
        Scope:Destroy();
    else
        Scope._hc = nil;
        Scope.ParentThread = nil;
        Scope.ConnectionsThread = nil;
        Scope._isCleanAncestor = nil;
        Scope.AnimationsAmount = nil;
        Scope.CleanWhenDone = nil;
        Scope.Cleaning = nil;
        for k = #Scope,1,-1 do
            local v = Scope[k]
            local type = typeof(v)
            if (type == "table" and v["Destroy"] ~= nil) or type == "Instance" then
                v:Destroy();
            elseif (type == "table" and v["Clean"]) then
                v:Clean()
            elseif type == "function" then
                v()
            elseif type == "RBXScriptConnection" then
                v:Disconnect();
            elseif type == "thread" then
                task.cancel(v);
            elseif type == "table" then
                if v.__isThread == true then
                    Recursive(v)
                else
                    tc(v)
                end
            end
            Scope[k] = nil;
        end
        setmetatable(Scope,nil);
        
        --tc(Scope)
    end
end
return function(Scope, NoDeletion: boolean?)
    Recursive(Scope,NoDeletion)
end
