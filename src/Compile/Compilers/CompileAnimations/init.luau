local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)

local Player = require(script.Player)
local Cleaner = require(script.Parent.Parent.Parent.Clean)
-- roblox services
local Tweenservice = game:GetService("TweenService")

-- anim helpers
local Lerps = require(script.Lerps)
local AnimatorStorage = require(script.Player.AnimatorStorage)

return function(Entity: Types.FayeInstance, Index: string, Anim: Types.Animation)
   local Thread = Entity.InnerThread or Entity.Thread;
   local PropertyType = Utility.tof(Entity.Instance[Index])
   if Anim.Loaded == true then
    --| run anims in parallel
    local AddedWorker
    if Anim.Workers == nil then
        AddedWorker = true;
        Anim.Workers = {Count = 0};
    end
    if Anim.IsPlaying == true then
        local AnimFetched = (AnimatorStorage.Holder ~= nil and AnimatorStorage.Holder[Anim.__animId]) or (AnimatorStorage.RegularTweenHolder ~= nil and AnimatorStorage.RegularTweenHolder[Anim.__animId])
        if AnimFetched ~= nil then
            if AnimFetched.Main == nil then
                --| custom tween
                if Anim.Initial ~= nil then
                    Entity[Index] = Anim.Initial;
                end
                local LocalDefault = Anim.Initial or Entity.Instance[Index];
                Anim.Workers[Anim.Workers.Count + 1] = {Entity = Entity.Instance,Property = Index,PropertyType = PropertyType,
                Default = LocalDefault,Lerp = Lerps[PropertyType](LocalDefault,AnimFetched.To)}
                if AddedWorker then
                    AnimFetched.Others = Anim.Workers;
                end
                --| custom tween end
            else
                --| roblox tween
                if AddedWorker then
                    AnimFetched.Others = {Count = 0}
                end
                if AnimFetched.Initial ~= nil then
                    Entity.Instance[Index] = AnimFetched.Initial;
                end
                AnimFetched.Others[AnimFetched.Others.Count + 1] = Tweenservice:Create(Entity.Instance,AnimFetched.Info,{
                    [Index] = AnimFetched.To
                });
                AnimFetched.Others[AnimFetched.Others.Count + 1]:Play()
                AnimFetched.Others.Count += 1;
                Anim.Workers[Anim.Workers.Count + 1] = {Entity = Entity.Instance,Property = Index,PropertyType = PropertyType;}
                --|>
            end
        end
    else
        if Anim.StartingSet ~= nil then
            Entity.Instance[Index] = Anim.StartingSet
        end
        Anim.Workers[Anim.Workers.Count + 1] = {Entity = Entity.Instance,Property = Index,PropertyType = PropertyType;}
    end
    Anim.Workers.Count += 1;
   else
    --| first compiler
    Anim.Loaded = true;
    --| info |--
    local InfoValue, infoConnectionsLength, infoConnections
    local function  mainInfoFunc(Info: any,Position: number,First)
        if Info == nil then return end;
        if Utility.tof(Info) ~= Utility.tabletxt then
            warn(`Info to set is not a table - {debug.traceback()}`)
            return
        end
        Position = Position or 1;
        if Info.__type ~= nil and ValueClasses[Info.__type] then
            infoConnectionsLength = Position;
            if infoConnections == nil then infoConnections = {} end;
            infoConnections[Position] = Info.Changed:Connect(function(NewInfo: any)
                if infoConnectionsLength > Position then
                    for i = infoConnectionsLength,Position+1,-1 do
                        infoConnections[i]:Disconnect();
                        infoConnections[i] = nil;
                    end
                end
                infoConnectionsLength = Position;
                mainInfoFunc(NewInfo,Position + 1)
            end,infoConnections)
            mainInfoFunc(Info:Get(), Position + 1,First)
        else
            InfoValue = Info
        end
    end
    if Anim.__onetimeinfo == nil then
        mainInfoFunc(Anim.Info,nil,true)
    end
    --||

    --| play trackers |--
    local UsedFrom
    --| Goal |--
    local InitialGoalType = Utility.tof(Anim.Goal)
    local IsInstanceValue = (InitialGoalType == Utility.instanceTxt and Anim.Goal:IsA(Utility.valueBaseTxt))
    local IsValue = IsInstanceValue or ( InitialGoalType == Utility.tabletxt and Anim.Goal.__type ~= nil and ValueClasses[Anim.Goal.__type])
    local goalConnectionsLength,goalConnections
    local id = Anim.__animId;
    local InstanceConnection
    --| delete portion
    local Delete; Delete = function (FromPlayer: boolean,Stop: boolean)
        if Anim ~= nil then
            Anim.IsPlaying = nil;
        end
        if Stop == nil then
            if InstanceConnection ~= nil then
                InstanceConnection:Disconnect();
                InstanceConnection = nil;
            end
            if Thread ~= nil then
                Utility.RemoveFromThread(Thread,Delete)
            end
            if goalConnectionsLength ~= nil and goalConnectionsLength >0 then
                Utility.ClearAllConnections(goalConnections,goalConnectionsLength)
            end
            if infoConnectionsLength ~= nil and infoConnectionsLength >0 then
                Utility.ClearAllConnections(infoConnections,infoConnectionsLength)
            end
            if Anim ~= nil then
                if Anim.Workers ~= nil then
                    Utility.tc(Anim.Workers)
                    Anim.Workers.Count = nil;
                    Anim.Workers = nil;
                end
                if not (Anim.DestroyOnClean == true) then
                    Utility.tc(Anim)
                end
                Anim.Loaded = nil;
                Anim.StartingSet = nil;
                Anim = nil;
            end
        end;
        --| on clean
        local Removed = Player.Remove(id)
        if Thread ~= nil and FromPlayer == true then
            
            if Thread.AnimationsAmount ~= nil and Removed then
                Thread.AnimationsAmount = Utility.max(Thread.AnimationsAmount - 1, 0)
            end
            if (Thread.CleanWhenDone and (Thread.AnimationsAmount ~= nil and Thread.AnimationsAmount <= 0)) then
                print("Delete ",Entity.Instance.Name)
                Thread.AnimationsAmount = nil
                Thread.CleanWhenDone = nil
                Thread:Remove(Delete)

                if Anim ~= nil then
                    Anim.Loaded = nil;
                    Anim.StartingSet = nil;
                end

                Anim = nil;
                Cleaner(Thread)
                Thread = nil;
            else
                print("No deletion on ",Entity.Instance.Name,Thread.AnimationsAmount,Thread.Signiture,id)
            end
        end;
        --|
    end
    --|> delete portion
    local function  mainGoalFunc(Goal: any,Position: number?,NoAnim: boolean?)
        if Goal == nil then return end;
        Position = Position or 1;
        local GaolType = typeof(Goal);
        local IsTable = GaolType == Utility.tabletxt
        local IsInstance = not IsTable and GaolType == Utility.instanceTxt and Goal:IsA(Utility.valueBaseTxt)
        if IsTable or IsInstance then
            if IsInstance or (Goal.__type ~= nil and ValueClasses[Goal.__type]) then
                if goalConnections == nil then goalConnections = {} end;
                goalConnectionsLength = Position;
                goalConnections[Position] = Goal.Changed:Connect(function(NewGoal: any)
                    if goalConnectionsLength > Position then
                        for i = goalConnectionsLength,Position+1,-1 do
                            goalConnections[i]:Disconnect();
                            goalConnections[i] = nil;
                        end
                    end
                    goalConnectionsLength = Position;
                    mainGoalFunc(NewGoal,Position + 1)
                end,goalConnections)
                mainGoalFunc((IsInstance and Goal.Value) or Goal:Get(), Position + 1,NoAnim)
            end
        else
            if Entity ~= nil and Entity.Instance ~= nil then
                if NoAnim then
                    Entity.Instance[Index] = Goal
                    Anim.StartingSet = Goal;
                else
                    Thread.AnimationsAmount = (Thread.AnimationsAmount or 0) + 1
                    local Initial = nil;
                    if Anim.From ~= nil and not UsedFrom then
                        Initial = Anim.From;
                        UsedFrom = true;
                    elseif Anim.AlwaysFrom then
                        Initial = Anim.AlwaysFrom;
                    end
                    Player.Remove(Anim.__animId)
                    Anim.IsPlaying = true;
                    Player.Add(Anim.__animId, Goal,InfoValue,Delete,Entity.Instance,Index,Anim.Workers,IsValue,PropertyType,Initial)
                    Initial = nil;
                end
            end
        end
    end
    mainGoalFunc(Anim.Goal,nil,IsValue)
    --||

    --| cleanup |--
    --Thread:Remove(Anim)
    if IsInstanceValue then
        InstanceConnection = Anim.Goal:GetPropertyChangedSignal("Parent"):Connect(function()
            if Anim == nil or Anim.Parent ==nil then
                Delete()
            end
        end)
    end
    Utility.AddToThread(Thread,Delete)
   end
end