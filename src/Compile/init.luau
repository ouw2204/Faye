--
local to = typeof
local tc = table.clear
local sf = string.find
local sb = string.sub

Compilers = require(script.Compilers)
local function Recursive(Entity: {Instance: Instance}, Props: {})
    for i,v in pairs(Props) do
        local toi = to(i);
        if Compilers[i] ~= nil then
            Compilers[i](Entity,i,v,Recursive)
        elseif to(v) == "table" then
            if v.__type ~= nil and Compilers[v.__type] then 
                Compilers[v.__type](Entity,i,v,Recursive);
            else
                Recursive(Entity,v);
            end
        elseif toi == "table" and Compilers[i.__type] then
            Compilers[i.__type](Entity,i,v,Recursive)
        else
            local onChangedIndex = sf(i,"OnChanged");
            if onChangedIndex ~= nil then
                local prop = sb(0,onChangedIndex+1);
                local Init = sf(i,"OnChangedInit") ~= nil;

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