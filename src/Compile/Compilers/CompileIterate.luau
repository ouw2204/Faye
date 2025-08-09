
local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)
local instancetxt,destroytxt,tabletxt,numbertxt = "Instance","Destroy","table","number"
local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
local SupportedValues = {
    NumberValue = true;
    IntConstrainedValue = true;
    IntValue = true;
}
local function  cleanIndividual(Holder: {any: any},Index: any)
    if Holder[Index] ~= nil then
        Utility.CallDestroy(Holder[Index])
        Holder[Index] = nil
    end
end

local function subCompile(IsNotAdvanced: boolean, Thread: Types.Thread, Function: (...any) -> any,Entity:  Types.FayeInstance, Holder: {[any]: any},Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> (),Index: any, Value: any, FirstIndex: any)
    if Index == nil or Value == nil then return end
    local EquippedIndex = FirstIndex or Index
    
    local NewThread
    if IsNotAdvanced then
        NewThread = Holder;
    else
        cleanIndividual(Holder, EquippedIndex)
        NewThread = Thread:Extend(true);
    end
    local res, res2 = Function(Index, Value, NewThread, Entity.Instance)
    local NewCompile
    if res2 == nil and res ~= nil then
        NewCompile = (Utility.tof(res) == Utility.tabletxt and res.__type == nil and res) or {res}
    elseif res ~= nil and res2 ~= nil then
        NewCompile = {[res] = res2}
    end
    if NewCompile ~= nil then
        if not IsNotAdvanced then
            Holder[EquippedIndex] = NewThread
        end
        local Entity = {Instance = Entity.Instance, Thread = NewThread}
        Compile(Entity, NewCompile, NewThread)
    else
        if IsNotAdvanced then
            Utility.CallDestroy(NewThread)
        end
    end
end

return function (Instance: Types.FayeInstance,_, Iterate: Types.Value,Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> ())
    local Thread = Instance.InnerThread or Instance.Thread;
    if Thread == nil or Thread["Extend"] == nil then warn("Iteterate only works if the entity has a thread and the thread has an :Extend method") return end;
    local IsNotAdvanced = not Iterate.Advanced
    --| go to the nearest cleaning thread in the ancestry
    if Thread._isCleanAncestor then
        local CurrentPos = Thread
        while CurrentPos ~= nil do
            if CurrentPos._hc then
                break;
            end
            CurrentPos = CurrentPos.ParentThread;
        end
        Thread = CurrentPos or Thread;
    end
    --|>

    local Holder = (IsNotAdvanced and Thread:Extend(true)) or {};
    local function cleanHolder(Refresh: boolean?)
        if IsNotAdvanced then
            print(11)
            if Holder ~= nil then
                Holder:Destroy();
                Holder = nil;
                print("destroy holder")
            end
            if Refresh then
                Holder = Thread:Extend(true)
            end
        else
            for _, v in pairs(Holder) do
                if v ~= nil and v[destroytxt] then
                    Utility.CallDestroy(v)
                end
            end
            Utility.tc(Holder)
            Holder = nil
            if Refresh then
                Holder = {};
            end
        end
        
    end
    local ConnectionsHolder
    local connectionslength;
    
    local function Delete(NotFromThread: boolean?)
        print("FIREDDDD")
        if NotFromThread then
            Utility.RemoveFromThread(Thread,Delete)
        end
        if ConnectionsHolder ~= nil then
            Utility.ClearAllConnections(ConnectionsHolder,connectionslength)
        end
        if Holder ~= nil then
            cleanHolder();
            Holder = nil;
        end
    end
    --| main func
    local function mainFunc(Content: Types.Value,Position: number?)
        if Content == nil then return end;
        local ContentType = Utility.tof(Content)
        local contentIsNumber = ContentType == numbertxt;
        local contentIsTable = ContentType == tabletxt
        local currentnumber;
        local ContentIsVlaue = not contentIsNumber and not contentIsTable and ContentType == instancetxt and SupportedValues[Content.ClassName]
        if not contentIsNumber and not contentIsTable and not ContentIsVlaue then return end;
        Position = Position or 1
        if contentIsNumber then
            cleanHolder(true);
            currentnumber = Content;
            for i = 1,Content do
                subCompile(IsNotAdvanced,Thread,Iterate.Function,Instance,Holder,Compile,i,i)
            end
        else
            if ContentIsVlaue or (Content.__type ~= nil and ValueClasses[Content.__type]) then
                connectionslength = Position;
                if ConnectionsHolder == nil then
                    ConnectionsHolder = {};
                end
                ConnectionsHolder[Position] = Content.Changed:Connect(function(__reserved, Index: any, NewValue: any?, ChangeType: number?, IsConventional: boolean?)
                    if Index == nil or ChangeType == nil or IsNotAdvanced then
                        Index = __reserved
                    end
                    if connectionslength > Position then
                        cleanHolder(true);
                        for i = connectionslength,Position+1,-1 do
                            ConnectionsHolder[i]:Disconnect();
                            ConnectionsHolder[i] = nil;
                        end
                    end
                    connectionslength = Position;
                    
                    if (NewValue == nil and ChangeType == nil) or IsNotAdvanced then
                        mainFunc(Index,Position + 1)
                    else
                        local vType = Utility.tof(Index)
                        local vtypeisnumber = vType == numbertxt;
                        --< is adds/remove
                        if vtypeisnumber and NewValue == nil and ChangeType ~= nil then
                            --< numb
                            
                            if Index >0 then
                                local current = currentnumber;
                                if ChangeType == 2 then
                                    currentnumber -= Index;
                                    for EqIndex = current, math.max(current - Index + 1, 1), -1 do
                                        if Holder[EqIndex] ~= nil then
                                            cleanIndividual(Holder,EqIndex)
                                        end
                                    end
                                else
                                    currentnumber += Index;
                                    for i = 1,Index do
                                        local final = i + current
                                        subCompile(IsNotAdvanced,Thread,Iterate.Function,Instance,Holder,Compile, final,final,final)
                                    end
                                end
                                current = nil
                            end
                            --> numb
                        else
                            --< is something else
                            local EqIndex = (IsConventional and NewValue) or Index
                            if ChangeType == 2 then
                                if Holder[EqIndex] ~= nil then
                                    cleanIndividual(Holder,EqIndex)
                                elseif Holder[Index] ~= nil then
                                    cleanIndividual(Holder,Index)
                                end
                            else
                                subCompile(IsNotAdvanced,Thread,Iterate.Function,Instance,Holder,Compile,Index, NewValue, EqIndex)
                            end
                            --> is something else
                        end
                        --> is adds/remove
                    end
                end,ConnectionsHolder)
                mainFunc( (ContentIsVlaue and Content.Value) or Content:Get(),Position + 1)
            else
                cleanHolder(true);
                local Count = 0;
                for i,v in pairs(Content) do
                    Count += 1;
                    subCompile(IsNotAdvanced,Thread,Iterate.Function,Instance,Holder,Compile,i,v,( i == Count and v) or nil )
                end
            end
        end
    end
    mainFunc(Iterate.Tab)
    --|> main func end
    Utility.AddToThread(Thread,Delete)
end