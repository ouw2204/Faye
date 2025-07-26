local to = typeof
local sf = string.find
local sb = string.sub
--local tc = table.clear
local tins = table.insert
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Compilers = require(script.Compilers)
local tablestr,numberstr,functionstr,RBXScriptSignalstr,ClearTableInCompulationstr = "table","number","function","RBXScriptSignal","ClearTableInCompulation"
local OnChangedInitstr,OnChangedstr,Valuestr,Instancestr,Addstr = "OnChangedInit","OnChanged","Value","Instance","Add"
local function Recursive(Entity: {Instance: any, Thread: any, InnerThread: any}, Props: any,InstanceThread: any)
    -- Main loop
    print(Props," are props")
    for i, v in pairs(Props) do
        if i == ClearTableInCompulationstr then continue end; -- Skip if the key is "ClearTableInCompulation"
        local tov = to(v)
        local toi = --[[tov == "table" and v.__type and to(v.__type) or]] to(i)
        local compilerFunc = (toi ~= tablestr and Compilers[i]) or nil
        if compilerFunc then
            compilerFunc(Entity, i, v, Recursive)
        elseif tov == Instancestr then
            v.Parent = Entity.Instance
            if InstanceThread ~= nil then
                if InstanceThread[Addstr] ~= nil then
                    InstanceThread:Add(v)
                else
                    tins(Instance,v);
                end
            end
        elseif tov == tablestr then
            local Type = v.__type and (ValueClasses[v.__type] and Valuestr or v.__type)

            if Type and Compilers[Type] then
                Compilers[Type](Entity, i, v, Recursive)
            else
                Recursive(Entity, v,InstanceThread)
            end
        elseif toi == tablestr and Compilers[i.__type] then
            Compilers[i.__type](Entity, i, v, Recursive)
        else
            if tov == functionstr and toi == numberstr then
                local ret = v(Entity.Instance)
                if ret then
                    Recursive(Entity, (to(ret) == tablestr and ret.__type == nil and ret) or {ret})
                end
            else
                local onChangedIndex = sf(i, OnChangedstr)
                if onChangedIndex then
                    local prop = sb(i, 1, onChangedIndex - 1) -- Adjusting for Lua's 1-based index
                    local Init = sf(i, OnChangedInitstr) ~= nil
                    if Props then
                        Compilers.OnChanged(Entity, prop, v, Recursive, Init)
                    end
                elseif to(Entity.Instance[i]) == RBXScriptSignalstr then
                    Compilers.EventCompiler(Entity, i, v,Recursive)
                else
                    if tov == functionstr then
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
        if Props[ClearTableInCompulationstr] then
            Props[i] = nil -- Avoid if Props is large
        end
    end
    Props.ClearTableInCompulation = nil;
    --tc(Props)
end

return function(Entity: {Instance: Instance, Thread: any, InnerThread: any}, Props: {},...)
    if Props.__type ~= nil and Compilers[Props.__type] then
        print("A")
        Compilers[Props.__type](Entity,1, Props, Recursive, ...)
    else
        print(Entity,Props)
        Recursive(Entity, Props,...)
    end
end
