local tf, tins, tr, tof, tc = table.find, table.insert, table.remove, typeof, table.clear
local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)

return function(Entity: Types.Instance, Index: string, Value: Types.Animation)
    local infoConnections = {}
    local infoConnectionsLength = 0;
    local goalConnections = {};
    local goalConnectionsLength = 0;
    local Info = Value.Info;
    Value.Info = nil;
    Value.Entity = Entity.Instance
	Value.Property = Index
    local Thread = Entity.InnerThread or Entity.Thread
    --switching threads
    if Thread ~= nil and (Value.Thread == nil or Thread ~= Value.Thread) then
        if Value.Thread ~= nil then
            Utility.RemoveFromThread(Value.Thread,Value)
        end
        Value.Thread = Thread
        Utility.AddToThread(Thread,Value)
    end
    -->


    local function  mainInfoFunc(Info: any,Position: number)
        if Info == nil then return end;
        if tof(Info) ~= "table" then
            warn(`Info to set is not a table - {debug.traceback()}`)
            return
        end
        Position = Position or 1;
        if Info.__type ~= nil and ValueClasses[Info.__type] then
            infoConnectionsLength = Position;
            infoConnections[Position] = Info.Changed:Connect(function(NewInfo: any)
                if infoConnectionsLength > Position then
                    for i = infoConnectionsLength,Position+1,-1 do
                        infoConnections[i]:Disconnect();
                        infoConnections[i] = nil;
                    end
                end
                infoConnectionsLength = Position;
                mainInfoFunc(NewInfo,Position + 1)
            end)
            mainInfoFunc(Info:Get(), Position + 1)
        else
            Value:UpdateInfo(Info)
        end
    end
    if Value.__onetimeinfo == nil then
        mainInfoFunc(Info)
    end
    local function  mainGoalFunc(Goal: any,Position: number?,NoAnim: boolean?)
        if Goal == nil then return end;
        Position = Position or 1;
        local goalType = typeof(Goal);
        if goalType == "table" then
            if Goal.__type ~= nil and ValueClasses[Goal.__type] then
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
                end)
                mainGoalFunc(Goal:Get(), Position + 1,NoAnim)
            end
        else
            if Entity ~= nil and Entity.Instance ~= nil then
                if NoAnim--[[ or Value.SkipToGoal]] and Value.Initial == nil then
                    --[[if NoAnim == nil then
                        Value.SkipToGoal = nil;
                    end]]
                    NoAnim = nil
                    if Value.Property ~= nil and tof(Entity.Instance[Value.Property]) == goalType then
                        Entity.Instance[Value.Property] = Goal
                    end
                else
                    if Value.Property ~= nil and tof(Entity.Instance[Value.Property]) == goalType then
                        Value.Elapsed = nil
                        if Value.__onetimeinfo ~= nil or Value.__cleantempinfo then
                            if Value.__cleantempinfo then
                                Value.__onetimeinfo = nil
                                Value.__cleantempinfo = nil
                                Utility.ClearAllConnections(infoConnections,infoConnectionsLength)
                                mainInfoFunc(Info)
                            else
                                Value:UpdateInfo(Value.__onetimeinfo)
                                Value.__cleantempinfo = true
                            end
                        end
                        Value:Play(Goal)
                    end
                end
            end
        end
    end
    if tof(Value.Goal) == "table" then
        if Value.Goal.__type ~= nil and ValueClasses[Value.Goal.__type] then
            mainGoalFunc(Value.Goal,nil,true )
        end
    else
        mainGoalFunc(Value.Goal)
    end
    

    local id = math.random(1,999)
    local Clean; Clean = function()
        Value.__cleanFunction = nil;
        Utility.ClearAllConnections(infoConnections,infoConnectionsLength)
        Utility.ClearAllConnections(goalConnections,goalConnectionsLength)
        tc(goalConnections)
        tc(infoConnections)
        goalConnections = nil;
        infoConnections = nil;
        infoConnectionsLength = nil;
        goalConnectionsLength = nil;
        --print("clean ",script.Name)
    end
    Value.__cleanFunction = Clean
end