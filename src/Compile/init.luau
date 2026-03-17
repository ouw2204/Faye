local to = typeof
local sf = string.find
local sb = string.sub
--local tc = table.clear
local tins = table.insert
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local Compilers = require(script.Compilers)
local tablestr,numberstr,functionstr,RBXScriptSignalstr = "table","number","function","RBXScriptSignal"
local OnChangedInitstr,OnChangedstr,Valuestr,Instancestr,Addstr,valuebasestr = "OnChangedInit","OnChanged","Value","Instance","Add","ValueBase"
local Aftertxt,BeforeTxt = "After","Before"
local UseCompile = require(script.Parent.Misc.UseCompilePassRecursiveness)
local function Recursive(Entity: {Instance: any, Thread: any, InnerThread: any}, Props: any,InstanceThread: any)
    -- Main loop
    if Props[BeforeTxt] then
        local Beforetype = to(Props.Before)
        if Beforetype == functionstr then
            local r1,r2 = Props.Before(Entity.Instance)
            if r1 ~= nil then
                UseCompile(Recursive, r1,r2,Entity,Entity.InnerThread or Entity.Thread)
            end
        elseif Beforetype == tablestr then
            Recursive(Entity, Props.Before,InstanceThread)
        end
    end
    for i, v in pairs(Props) do
        if i == Aftertxt or i == BeforeTxt then continue end;
        local tov = to(v)
        local toi = --[[tov == "table" and v.__type and to(v.__type) or]] to(i)
        local compilerFunc = (toi ~= tablestr and Compilers[i]) or nil
        if compilerFunc then
            compilerFunc(Entity, i, v, Recursive)
        elseif tov == Instancestr then
            --> instance compile
            if toi == numberstr then
                --object parenting
                v.Parent = Entity.Instance
                if InstanceThread ~= nil then
                    if InstanceThread[Addstr] ~= nil then
                        InstanceThread:Add(v)
                    else
                        tins(Instance,v);
                    end
                end
            else
                -- supported values
                if v:IsA(valuebasestr) then
                    Compilers.Value(Entity, i, v)
                end
            end
        elseif tov == tablestr then
            local Type = v.__type and (ValueClasses[v.__type] and Valuestr or v.__type)

            if Type == Instancestr and v.Instance then
                local inst = v.Instance
                if toi == numberstr then
                    inst.Parent = Entity.Instance
                    if InstanceThread ~= nil then
                        if InstanceThread[Addstr] ~= nil then
                            InstanceThread:Add(inst)
                        else
                            tins(InstanceThread,inst);
                        end
                    end
                elseif inst:IsA(valuebasestr) then
                    Compilers.Value(Entity, i, inst)
                else
                    Entity.Instance[i] = inst
                end
            elseif Type and Compilers[Type] then
                Compilers[Type](Entity, i, v, Recursive)
            else
                Recursive(Entity, v,InstanceThread)
            end
        elseif toi == tablestr and Compilers[i.__type] then
            Compilers[i.__type](Entity, i, v, Recursive)
        else
            if tov == functionstr and toi == numberstr then
                local ret,ret2 = v(Entity.Instance)
                if ret then
                    UseCompile(Recursive, ret,ret2,Entity,Entity.InnerThread or Entity.Thread)
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
    end
    if Props[Aftertxt] then
        local aftertype = to(Props.After)
        if aftertype == functionstr then
            local r1,r2 = Props.After(Entity.Instance)
            if r1 ~= nil then
                UseCompile(Recursive,r1,r2,Entity,Entity.InnerThread or Entity.Thread)
            end
        elseif aftertype == tablestr then
            Recursive(Entity, Props.After,InstanceThread)
        end
    end
    --tc(Props)
end

return function(Entity: {Instance: Instance, Thread: any, InnerThread: any}, Props: {},...)
    Recursive(Entity, Props,...)
end
