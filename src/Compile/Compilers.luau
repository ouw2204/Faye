--
local tins,tf,tr = table.insert,table.find,table.remove
local tof = typeof
local ValueClasses = require(script.Parent.Parent.Misc.ValueClasses)
local CleanModule = require(script.Parent.Parent.Clean)
local tc = table.clear
local m = {
    SetTo = function(Entity,Index,Value)
        if Value["Value"] ~= nil and Value.Value["Set"] ~= nil then
            Value.Value:Set(Entity)
        end
        Value:Destroy();
    end;
    Instance = function(Entity,Index,Value,Compile)
        local Props = Value.Props;
        if Props ~= nil then
            Props.Parent = Props.Parent or Entity.Instance;
            Value:Compile()
        end
    end;
    OnChanged = function(Entity,Index,Value,Compile,Init)
        local Thread = Entity.InnerThread or Entity.Thread
        if Init == true then
            Value(Entity.Instance,Entity.Instance[Index])
        end
        Thread:Connect(Entity.Instance:GetPropertyChangedSignal(Index),function()
            Value(Entity.Instance,Entity.Instance[Index])
        end)
    end;
    Iterate = function(Entity,Index,Value,Compile)
        local Thread = Entity.InnerThread or Entity.Thread
        if Thread ~= nil and Thread ~= Value.Thread then
            if Value.Thread ~= nil then
                if Value.Thread["Remove"] then
                    Value.Thread:Remove(Value)
                else
                    local f = tf(Value.Thread,Value)
                    if f ~= nil then
                        tr(Value.Thread,f)
                    end
                end
            end
            Value.Thread = Thread;
            if Thread["Add"] then
                Thread:Add(Value)
            else
                tins(Thread,Value)
            end
        end
        local Holder = {};
        local Connect1,Connect2 = nil,nil;
        local function CleanHolder()
            for i,v in pairs(Holder) do
                if Thread["Remove"] then
                    Thread:Remove(v)
                else
                    local Pos = tf(Thread,v)
                    if Pos then
                        tr(Thread,Pos)
                    end
                end
                v:Clean()
            end
            tc(Holder)
        end
        --< main
        local function upd(Ind,Val)
            if Holder[Ind] ~= nil then
                if Thread["Remove"] then
                    Thread:Remove(Holder[Ind])
                else
                    local Pos = tf(Thread,Holder[Ind])
                    if Pos ~= nil then
                        tr(Thread,Pos)
                    end
                end
                Holder[Ind]:Clean()
                Holder[Ind] = nil;
            end
            local NewThread = Thread:Extend();
            local I,V = Value.Function(Ind,Val,NewThread,Entity.Instance)
            local NewCompile = {}
            if V == nil then
                tins(NewCompile,I)
            elseif I ~= nil and V ~= nil then
                NewCompile[I] = V;
            end
            Holder[Ind] = NewThread;
            Compile(Entity,NewCompile)
        end
        -->
        if Value.Tab ~= nil then
            if Value.Tab.__type ~= nil and ValueClasses[Value.Tab.__type] ~= nil then
                --first degree
                local function step(Index,Value,ChangeType)
                    if Value == nil then
                        CleanHolder()
                        if Connect2 ~= nil then
                            Connect2:Disconnect()
                            Connect2 = nil;
                        end
                        if tof(Index) == "table" then
                            if Index.__type ~= nil and ValueClasses[Index.__type] then
                                --second degree
                                local function innerSet(newIndex,newValue,newChangeType)
                                    if newValue == nil then
                                        if tof(newIndex) == "table" then
                                            if newIndex.__type ~= nil then
                                                warn(`Iterate only supports nested values up to the 2nd degree - {debug.traceback()}`)
                                            else
                                                CleanHolder()
                                                for i,v in pairs(newIndex) do
                                                    upd(i,v)
                                                end
                                            end
                                        end
                                    else
                                        if newChangeType == 2 then
                                            if Holder[newIndex] ~= nil then
                                                if Thread["Remove"] then
                                                    Thread:Remove(Holder[newIndex])
                                                else
                                                    local Pos = tf(Thread,Holder[newIndex])
                                                    if Pos ~= nil then
                                                        tr(Thread,Pos)
                                                    end
                                                end
                                                Holder[newIndex]:Clean();
                                                Holder[newIndex] = nil;
                                            end
                                        else
                                            upd(newIndex,newValue)
                                        end
                                    end
                                end
                                innerSet(Index:Get())
                                Connect2 = Index.Changed:Connect(innerSet)
                            else
                                for i,v in pairs(Index) do
                                    upd(i,v)
                                end
                            end
                        end
                    else
                        if ChangeType == 2 then
                            if Holder[Index] ~= nil then

                                if Thread["Remove"] then
                                    Thread:Remove(Holder[Index])
                                else
                                    local Pos = tf(Thread,Holder[Index])
                                    if Pos ~= nil then
                                        tr(Thread,Pos)
                                    end
                                end
                                
                                Holder[Index]:Clean();
                                Holder[Index] = nil;
                            end
                        else
                            upd(Index,Value)
                        end
                    end
                end
                step(Value.Tab:Get())
                Connect1 = Value.Tab.Changed:Connect(step)
            else
                CleanHolder()
                for i,v in pairs(Value.Tab) do
                    upd(i,v)
                end
            end
        end
        if Thread ~= nil then
            local function Clean()
                if Connect1 then
                    Connect1:Disconnect();
                    Connect1 = nil;
                end
                if Connect2 then
                    Connect2:Disconnect();
                    Connect2 = nil;
                end
                CleanHolder();
            end
            if Thread["Add"] then
                Thread:Add(Clean)
            else
                tins(Thread,Clean)
            end
        end

    end;

    --<Do/State
    Do = function(Entity,Index,Value)
        local Thread = Entity.InnerThread or Entity.Thread
        if Thread ~= nil and Thread ~= Value.Thread then
            if Value.Thread ~= nil then
                if Value.Thread["Remove"] then
                    Value.Thread:Remove(Value)
                else
                    local f = tf(Value.Thread,Value)
                    if f ~= nil then
                        tr(Value.Thread,f)
                    end
                end
            end
            Value.Thread = Thread;
            if Thread["Add"] then
                Thread:Add(Value)
            else
                tins(Thread,Value)
            end
        end
        Value.Entity = Entity;
        if (tof(Index) ~= "number") then
            Value.Property = Index;
        end
        Value:Initiate();
    end;
    State = function(Entity,Index,Value)
        local Thread = Entity.InnerThread or Entity.Thread
        if Thread ~= nil and Thread ~= Value.Thread then
            if Value.Thread ~= nil then
                if Value.Thread["Remove"] then
                    Value.Thread:Remove(Value)
                else
                    local f = tf(Value.Thread,Value)
                    if f ~= nil then
                        tr(Value.Thread,f)
                    end
                end
            end
            Value.Thread = Thread;
            if Thread["Add"] then
                Thread:Add(Value)
            else
                tins(Thread,Value)
            end
        end
        Value.Entity = Entity;
        if (tof(Index) ~= "number") then
            Value.Property = Index;
        end
        Value:Initiate();
    end;
    --> Do/State



    Animate = function(Entity,Index,Value)
        local Goal = Value.Goal;
        local Info = Value.Info;
        local Thread = Entity.InnerThread or Entity.Thread

        --switching threads
        if Thread ~= nil and (Value.Thread == nil or Thread ~= Value.Thread) then
            if Value.Thread ~= nil then
                if Value.Thread["Remove"] then
                    Value.Thread:Remove(Value)
                else
                    local f = tf(Value.Thread,Value)
                    if f ~= nil then
                        tr(Value.Thread,f)
                    end
                end
            end;
            Value.Thread = Thread;
            if Thread["Add"] then
                Thread:Add(Value)
            else
                tins(Thread,Value)
            end
        end
        -->

        Value.Entity = Entity.Instance;
        Value.Property = Index;
        local InfoConnect1,InfoConnect2,GoalConnect1,GoalConnect2 = nil,nil,nil,nil;
        do-- info
            local function setInfo(NewInfo)
                if Value.Info ~= nil then
                    Value.Info = nil;
                end
                if InfoConnect2 ~= nil then
                    InfoConnect2:Disconnect()
                    InfoConnect2 = nil;
                end
                if tof(NewInfo) == "table" then
                    if NewInfo.__type ~= nil and ValueClasses[NewInfo.__type] ~= nil then
                        --inner value is another value
                        local function InnerUpdate(newnewValue)
                            if Value.Info ~= nil then
                                Value.Info = nil;
                            end
                            --set value from nested value
                            if tof(newnewValue) == "table" and newnewValue.__type ~= nil then
                                warn(`Nested values only support up to 2 degrees of nesting - {debug.traceback()}`)
                            else
                                Value:UpdateInfo(newnewValue)
                            end
                        end
                        InnerUpdate(NewInfo:Get())
                        InfoConnect2 = NewInfo.Changed:Connect(InnerUpdate) --connect change connection
                    else
                        --is reg table
                        Value:UpdateInfo(NewInfo)
                    end
                else
                    warn(`Info to set is not a table - {debug.traceback()}`)
                end
            end
            
            if tof(Info) == "table" and Info.__type ~= nil and ValueClasses[Info.__type] ~= nil then
                setInfo(Info:Get());
                InfoConnect1 = Info.Changed:Connect(setInfo)
            else
                setInfo(Info)
            end
        end
        do -- Goal
            local function setGoal(NewGoal,NoAnim)
                if GoalConnect2 ~= nil then
                    GoalConnect2:Disconnect()
                    GoalConnect2 = nil;
                end
                if tof(NewGoal) == "table" then
                    if NewGoal.__type ~= nil and ValueClasses[NewGoal.__type] ~= nil then
                        --inner value is another value
                        local function InnerUpdate(newnewGoal)
                            --set value from nested value
                            if tof(newnewGoal) == "table" then
                                if newnewGoal.__type ~= nil then
                                    warn(`Nested values only support up to 2 degrees of nesting - {debug.traceback()}`)
                                else
                                    warn(`Goal value can not be a table - {debug.traceback()}`)
                                end
                            else
                                if NoAnim or Value.SkipFirstValue then
                                    if NoAnim == nil then
                                        Value.SkipFirstValue = nil;
                                    end
                                    NoAnim = nil;
                                    if tof(Entity.Instance[Value.Property]) == tof(newnewGoal) then
                                        Entity.Instance[Value.Property] = newnewGoal;
                                    end
                                else
                                    if tof(Entity.Instance[Value.Property]) == tof(NewGoal) then
                                        Value.Elapsed = nil;
                                        Value:Play(newnewGoal)
                                    end
                                end
                            end
                        end
                        InnerUpdate(NewGoal:Get())
                        GoalConnect2 = NewGoal.Changed:Connect(InnerUpdate) --connect change connection
                    end
                else
                    if NoAnim or Value.SkipFirstValue then
                        if NoAnim == nil then
                            Value.SkipFirstValue = nil;
                        end
                        NoAnim = nil;
                        if tof(Entity.Instance[Value.Property]) == tof(NewGoal) then
                            Entity.Instance[Value.Property] = NewGoal;
                        end
                    else
                        if tof(Entity.Instance[Value.Property]) == tof(NewGoal) then
                            Value.Elapsed = nil;
                            Value:Play(NewGoal)
                        end
                    end
                end
            end
            
            if tof(Goal) == "table" then
                if Goal.__type ~= nil and ValueClasses[Goal.__type] ~= nil then
                    setGoal(Goal:Get(),true);
                    GoalConnect1 = Goal.Changed:Connect(setGoal)
                end;
            else
                setGoal(Goal)
            end
        end

        --clean
        if Thread ~= nil then 
            local cleanFunction = function() -- clean function setup
                if InfoConnect1 ~= nil then -- main update signal disconnect
                    InfoConnect1:Disconnect()
                    InfoConnect1 = nil;
                end
                if InfoConnect2 ~= nil then -- nested update signal disconnect
                    InfoConnect2:Disconnect();
                    InfoConnect2 = nil;
                end

                if GoalConnect1 ~= nil then -- main update signal disconnect
                    GoalConnect1:Disconnect()
                    GoalConnect1 = nil;
                end
                if GoalConnect2 ~= nil then -- nested update signal disconnect
                    GoalConnect2:Disconnect();
                    GoalConnect2 = nil;
                end
            end
            if Thread["Add"] then -- if thread is an object like janitor,etc
                Thread:Add(cleanFunction)
            else
                table.insert(Thread,cleanFunction) -- if thread is a regular table
            end
        end
        Goal = nil;
        Info = nil;
        Thread = nil;
    end;
    Event = function(Entity,Index,Value)
        local Thread = Entity.InnerThread or Entity.Thread -- fetching innerthread or thread with priority
        if Thread ~= nil then -- thread exist
            if Thread["Add"] ~= nil then -- is a specialized cleaner
                Thread:Add(Entity.Instance[Index]:Connect(function(...)
                    Value(Entity.Instance,...)
                end))
            else
                tins(Thread,Entity.Instance[Index]:Connect(function(...)
                    Value(Entity.Instance,...)
                end))
            end
        else -- no threads
            Entity.Instance[Index]:Connect(function(...)
                Value(Entity.Instance,...)
            end)
        end
        Thread = nil;
    end;
    Value = function(Entity,Index,Value)
        local ChangedConnection = nil;
        local function updateValue(new)
            --setting the value
            if ChangedConnection ~= nil then
                ChangedConnection:Disconnect();
                ChangedConnection = nil;
            end
            if tof(new) == "table" then
                --the value is a table
                if new.__type ~= nil and ValueClasses[new.__type] ~= nil then
                    --is nested state
                    local function InnerUpdate(newValue)
                        --set value from nested value
                        if tof(newValue) == "table" then
                            warn(`Nested values only support up to 2 degrees of nesting - {debug.traceback()}`)
                        else
                            local tofIndex = tof(Entity.Instance[Index])
                            local tofNew = tof(newValue)
                            if tofIndex == tofNew or ((tofIndex == "number" or tofIndex == "string") and (tofNew == "number" or tofNew == "string")) then
                                Entity.Instance[Index] = newValue;
                            end
                            tofIndex = nil;
                            tofNew = nil;
                        end
                    end
                    InnerUpdate(new:Get())
                    ChangedConnection = new.Changed:Connect(InnerUpdate) --connect change connection
                end
            else
                local tofIndex = tof(Entity.Instance[Index])
                local tofNew = tof(new)
                if tofIndex == tofNew or ((tofIndex == "number" or tofIndex == "string") and (tofNew == "number" or tofNew == "string")) then
                    Entity.Instance[Index] = new;
                end
                tofIndex = nil;
                tofNew = nil;
            end
        end 
        --init
        updateValue(Value:Get())
        local connectMain = Value.Changed:Connect(updateValue) -- initial on change signal
        --clean
        local Thread = Entity.InnerThread or Entity.Thread --innerthread or thread
        if Thread ~= nil then 
            local cleanFunction = function() -- clean function setup
                if connectMain ~= nil then -- main update signal disconnect
                    connectMain:Disconnect()
                    connectMain = nil;
                end
                if ChangedConnection ~= nil then -- nested update signal disconnect
                    ChangedConnection:Disconnect();
                    ChangedConnection = nil;
                end
            end
            if Thread["Add"] then -- if thread is an object like janitor,etc
                Thread:Add(cleanFunction)
            else
                table.insert(Thread,cleanFunction) -- if thread is a regular table
            end
        end
        Thread = nil;
    end
}


return m;