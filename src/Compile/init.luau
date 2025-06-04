local to = typeof
local sf = string.find
local sb = string.sub
--local tc = table.clear
local tins = table.insert
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Compilers = require(script.Compilers)

local function Recursive(Entity: {Instance: any, Thread: any, InnerThread: any}, Props: any,InstanceThread: any)
    -- Main loop
    for i, v in pairs(Props) do
        if i == "ClearTableInCompulation" then continue end; -- Skip if the key is "ClearTableInCompulation"
        local tov = to(v)
        local toi = tov == "table" and v.__type and to(v.__type) or to(i)
        local compilerFunc = Compilers[i]
        if compilerFunc then
            compilerFunc(Entity, i, v, Recursive)
        elseif tov == "Instance" then
            v.Parent = Entity.Instance
            if InstanceThread ~= nil then
                if InstanceThread["Add"] ~= nil then
                    InstanceThread:Add(v)
                else
                    tins(Instance,v);
                end
            end
        elseif tov == "table" then
            local Type = v.__type and (ValueClasses[v.__type] and "Value" or v.__type)

            if Type and Compilers[Type] then
                Compilers[Type](Entity, i, v, Recursive)
            else
                Recursive(Entity, v,InstanceThread)
            end
        elseif toi == "table" and Compilers[i.__type] then
            Compilers[i.__type](Entity, i, v, Recursive)
        else
            if tov == "function" and toi == "number" then
                local ret = v(Entity.Instance)
                if ret then
                    Recursive(Entity, (to(ret) == "table" and ret.__type == nil and ret) or {ret})
                end
            else
                local onChangedIndex = sf(i, "OnChanged")
                if onChangedIndex then
                    local prop = sb(i, 1, onChangedIndex - 1) -- Adjusting for Lua's 1-based index
                    local Init = sf(i, "OnChangedInit") ~= nil
                    if Props then
                        Compilers.OnChanged(Entity, prop, v, Recursive, Init)
                    end
                elseif to(Entity.Instance[i]) == "RBXScriptSignal" then
                    Compilers.Event(Entity, i, v,Recursive)
                else
                    if tov == "function" then
                        local result = v(Entity.Instance)
                        if result ~= nil then
                            Entity.Instance[i] = result;
                        end
                    else
                        Entity.Instance[i] = v
                    end
                    
                end
            end
        end
        if Props["ClearTableInCompulation"] then
            Props[i] = nil -- Avoid if Props is large
        end
    end
    Props.ClearTableInCompulation = nil;
    --tc(Props)
end

return function(Entity: {Instance: Instance, Thread: any, InnerThread: any}, Props: {},...)
    Recursive(Entity, Props,...)
end
