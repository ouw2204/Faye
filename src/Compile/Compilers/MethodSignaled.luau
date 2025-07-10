local Types = require(script.Parent.Parent.Parent.Types)
local repeatedCompile = require(script.Parent.repeatedCompile)
local tins = table.insert
return function (Entity: Types.FayeInstance, Index: any, Value: Types.Value,Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> () )
    local Instance = Entity.Instance
    local Thread = Entity.InnerThread or Entity.Thread -- fetching innerthread or thread with priority
    local Signal = Instance[Index.Method](Instance,Index.Index)
    Index:Destroy();
    if Thread ~= nil then -- thread exist
        if Thread["Connect"] ~= nil then
            Thread:Connect(Signal, function(...)
                local Ret = Value(Instance,...)
                if Ret ~= nil then
                    repeatedCompile(Index, Thread, Ret, Compile, Entity)
                    Ret = nil
                end
            end)
        elseif Thread["Add"] ~= nil then -- is a specialized cleaner
            Thread:Add(
                Signal:Connect(function(...)
                    local Ret = Value(Instance,...)
                    if Ret ~= nil then
                        repeatedCompile(Index, Thread, Ret, Compile, Entity)
                        Ret = nil
                    end
                end),
                true
            )
        else
            tins(
                Thread,
                Signal:Connect(function(...)
                    local Ret = Value(Instance,...)
                    if Ret ~= nil then
                        repeatedCompile(Index, Thread, Ret, Compile, Entity)
                        Ret = nil
                    end
                end)
            )
        end
    else -- no threads
        Signal:Connect(function(...)
            local Ret = Value(Instance,...)
            if Ret ~= nil then
                repeatedCompile(Index, Thread, Ret, Compile, Entity)
                Ret = nil
            end
        end)
    end
    Signal = nil;
end