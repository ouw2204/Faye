--add a __isThread = true variable in all your custom threads to make sure this cleans nested threads instead of just clearing nested tables without cleaning the components in it.
local tc = table.clear
function Recursive(Scope)
    if Scope["Destroy"] ~= nil then
        Scope:Destroy();
    else
        for k = #Scope,1,-1 do
            local v = Scope[k]
            Scope[k] = nil;
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
        end
        setmetatable(Scope,nil);
        tc(Scope)
    end
end
return function(Scope)
    Recursive(Scope)
end
