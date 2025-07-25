
local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)
local extendtxt,destroytxt,tabletxt,numbertxt = "Extend","Destroy","table","number"
local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)

local function  cleanIndividual(Holder: {any: any},Index: any)
    if Holder[Index] ~= nil then
        Holder[Index]:Destroy()
        Holder[Index] = nil
    end
end

local function subCompile(Thread: Types.Thread, Function: (...any) -> any,Entity:  Types.FayeInstance, Holder: {[any]: any},Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> (),Index: any, Value: any, FirstIndex: any)
    if Index == nil or Value == nil then return end
    local EquippedIndex = FirstIndex or Index
    cleanIndividual(Holder, EquippedIndex)
    local NewThread = Thread:Extend();

    local I, V = Function(Index, Value, NewThread, Entity.Instance)
    local NewCompile
    if V == nil then
        NewCompile = {I}
    elseif I ~= nil and V ~= nil then
        NewCompile = {[I] = V}
    end
    if NewCompile ~= nil then
        Holder[EquippedIndex] = NewThread
        Compile(Entity, NewCompile, NewThread)
    else
        print("Nothing was returned from the iterate function, this is likely a bug in the code.")
        Utility.CallDestroy(NewThread)
    end
end

local function cleanHolder(Holder: {[any]: any})
    for i, v in pairs(Holder) do
        if v ~= nil and v[destroytxt] then
            v:Destroy()
        else
            print("Failed to clean ",v," its missing a destroy function.")
        end
    end
    Utility.tc(Holder)
end

return function (Instance: Types.FayeInstance,_, Iterate: Types.Value,Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> ())
    local Thread = Instance.InnerThread or Instance.Thread;
    if Thread == nil or Thread["Extend"] == nil then warn("Iteterate only works if the entity has a thread and the thread has an :Extend method") return end;
    if Iterate.Compiled then
        if Iterate.Others == nil then
            Iterate.Others = {Count = 0}
        end
        Iterate.Others[Iterate.Others.Count + 1] = Instance;
        Iterate.Others.Count += 1;
    else
        local Holder = {};
        local ConnectionsHolder = {};
        local connectionslength = 0;
        local function Delete()

        end
        --| main func
        local function mainFunc(Content: Types.Value,Position: number?)
		if Content == nil then return end;
            local ContentType = Utility.tof(Content)
            local contentIsNumber = ContentType == numbertxt;
            local contentIsTable = ContentType == tabletxt
            if not contentIsNumber and not contentIsTable then return end;
            Position = Position or 1
            if contentIsNumber then
                cleanHolder(Holder);
                currentnumber = Content;
                for i = 1,Content do
                    subCompile(Thread,Iterate.Function,Instance,Holder,Compile,i,i)
                end
            else
                if Content.__type ~= nil and ValueClasses[Content.__type] then
                    connectionslength = Position;
                    ConnectionsHolder[Position] = Content.Changed:Connect(function(__reserved, Index: any, NewValue: any?, ChangeType: number?, IsConventional: boolean?)
                        if Index == nil or ChangeType == nil then
                            Index = __reserved
                        end
                        if connectionslength > Position then
                            cleanHolder(Holder);
                            for i = connectionslength,Position+1,-1 do
                                ConnectionsHolder[i]:Disconnect();
                                ConnectionsHolder[i] = nil;
                            end
                        end
                        connectionslength = Position;
                        local vType = Utility.tof(Index)
                        local vtypeisnumber = vType == numbertxt;
                        if NewValue == nil and ChangeType == nil then
                            mainFunc(Index,Position + 1)
                        else
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
                                            subCompile(Thread,Iterate.Function,Instance,Holder,Compile, final,final,final)
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
                                        cleanIndividual(Holder,EqIndex)
                                    end
                                else
                                    subCompile(Thread,Iterate.Function,Instance,Holder,Compile,Index, NewValue, EqIndex)
                                end
                                --> is something else
                            end
                            --> is adds/remove
                        end
                    end,ConnectionsHolder)
                    mainFunc(Content:Get(),Position + 1)
                else
                    cleanHolder(Holder);
                    for i,v in pairs(Content) do
                        subCompile(Thread,Iterate.Function,Instance,Holder,Compile,i,v,(tonumber(i) and v) or nil )
                    end
                end
            end
        end
        mainFunc(Iterate.Tab)
        --|> main func end
        Thread:Add(Delete)
    end

    
end