--
local to = typeof
local tc = table.clear
local sf = string.find
local sb = string.sub
local ValueClasses = require(script.Parent.Misc.ValueClasses)
Compilers = require(script.Compilers)
local function Recursive(Entity: {Instance: Instance}, Props: {})
    for i,v in pairs(Props) do
        local toi = to(i);
        if Compilers[i] ~= nil then
            Compilers[i](Entity,i,v,Recursive)
        elseif to(v) == "table" then
            local Type = nil;
            if v.__type ~= nil then
                if ValueClasses[v.__type] then
                    Type = "Value"
                else
                    Type = v.__type;
                end
            end
            if Type ~= nil and Compilers[Type] then 
                Compilers[Type](Entity,i,v,Recursive);
            else
                Recursive(Entity,v);
            end
            Type = nil;
        elseif toi == "table" and Compilers[i.__type] then
            Compilers[i.__type](Entity,i,v,Recursive)
        else
            local onChangedIndex = sf(i,"OnChanged");
            if onChangedIndex ~= nil then
                local prop = sb(i,0,onChangedIndex-1);
                local Init = sf(i,"OnChangedInit") ~= nil;
                if Props ~= nil then
                    Compilers.OnChanged(Entity,prop,v,Recursive,Init)
                end
                prop = nil;
                Init = nil;
            elseif to(Entity.Instance[i]) == "RBXScriptSignal" then
                onChangedIndex = nil;
                Compilers.Event(Entity,i,v,Recursive)
            else
                onChangedIndex = nil;
                Entity.Instance[i] = v;
            end
            onChangedIndex = nil;
        end
        toi = nil;
        Props[i] = false;
   end
   tc(Props)
end
return function(Entity: {Instance: Instance}, Props: {})
   Recursive(Entity,Props);
end