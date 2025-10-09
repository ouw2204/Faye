local Types = require(script.Parent.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Parent.Misc.FayeUtility)
local m = {}

--Lists
local Storage = require(script.AnimatorStorage);
local OverlapFixer = require(script.OverlapFixer)

-- roblox services
local RunService = game:GetService("RunService")
local Tweenservice = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- anim functions
local Lerps = require(script.Parent.Lerps)
local Spring = require(script.Parent.Spring);

--Defaults
local DefaultEasingStyle = Enum.EasingStyle.Linear
local DefaultEasingDirection = Enum.EasingDirection.Out

--rep txt
local easingStyleTxt,numbertxt = "EasingStyle","number"

--rep functions
function ApplyProperty(Entity: Instance,PropertyType: string,Property: string,To: any,Default: any,Pivot: number,Lerp: (Pivot: number) -> (),EndReached: boolean,IsBasic)
    if PropertyType == numbertxt then
        Entity[Property] = Default+ ((To-Default)*Pivot);
    elseif Lerp ~= nil then
        if IsBasic then
            for _,v in Lerp do
                Entity[v[1]] = v[2](Pivot)
            end
        else
            Entity[Property] = Lerp(Pivot)
        end
    end
end
function update(delta: number)
    --| disconnect step if anim count is 0 |--
    if Storage.Count == 0 then
        Storage.Step:Disconnect()
        Storage.Step = nil;
    end
    --|
    for i = Storage.Count,1,-1 do
        local Id = Storage.Ids[i]
        local Anim = Storage.Holder[Id]
        if Anim ~= nil then
            
            if Anim.Entity ~= nil and Anim.Entity.Parent ~= nil then
                Anim.Elapsed += delta;
                if Anim.Ran == false then
                    warn(`Animation: {Id} Errored.`)
                    Anim.Delete(true)
                    continue
                end
                Anim.Ran = false;

                --| prog
                if Anim.Elapsed <= Anim.DelayTime and Anim.Direction then
                    Anim.Ran = true;
                    continue
                end

                local Prog = Utility.max( (Anim.Elapsed-Anim.DelayTime) % Anim.Time,0)
                local NatureProg = Prog
                local MaxProg = 1;
                if Anim.Direction == false then
                    MaxProg = 0;
                    Prog = Anim.Time-Prog;
                end
                Prog /= Anim.Time;
                --|> prog

                local EndReached = nil;
                local Pivot = MaxProg;
                if Anim.ProgBefore ~= nil and NatureProg < Anim.ProgBefore then
                    if Anim.Reverse == true and Anim.Direction == true then
                        Anim.Direction = false;
                    else
                        Anim.Direction = true;
                        
                        if Anim.RepeatsLeft == 0 then
                            EndReached = true;
                        else
                            if Anim.Reverse then
                                Anim.ProgBefore = nil;
                                Anim.Elapsed = 0;
                            end
                            if Anim.RepeatsLeft >=1 then
                                Anim.RepeatsLeft -=1
                            end
                        end
                    end
                else
                    --Animate
                    if Anim.EasingStyle ~= nil then
                        Pivot =  Tweenservice:GetValue(Prog,Anim.EasingStyle,Anim.EasingDirection)
                    elseif Anim.Frequency ~=  nil then
                        Pivot = Spring(Prog,Anim.Frequency,Anim.Damping)
                    end
                    --set
                end

                --| apply property
                ApplyProperty(Anim.Entity,Anim.PropertyType,Anim.Property,Anim.To,Anim.Default,Pivot,Anim.Lerp,EndReached,Anim.IsBasic)
                if Anim.Others ~= nil then
                    for x = 1,Anim.Others.Count do
                        ApplyProperty(Anim.Others[x].Entity,Anim.Others[x].PropertyType,Anim.Others[x].Property,Anim.To,Anim.Others[x].Default,Pivot,Anim.Others[x].Lerp,EndReached)
                    end
                end
                --|> apply property
                if EndReached then
                    if Anim.IsValue then
                        Anim.Delete(true,true);
                    else
                        Anim.Delete(true)
                    end
                    EndReached = nil;
                    MaxProg = nil;
                    Pivot = nil;
                    continue
                end
                Anim.Ran = true;
                EndReached = nil;
                MaxProg = nil;
                Pivot = nil;
                if Anim.Elapsed ~= 0 then
                    Anim.ProgBefore = NatureProg;
                end
            else
                if Anim.Delete ~= nil then
                    Anim.Delete();
                else
                    m.Remove(Id)
                end
            end
        else
            Storage.Ids[i] = nil;
        end
    end
end

local EmptyString = "";
function  m.Add(Id: string,Goal: any, Info: (Types.Info | Types.SpringInfo)?, Delete: () -> (),Instance: Instance, Property: string, Others: { {Entity: Instance,Property: string} }?,IsValue: boolean?,PropertyType: string,Initial: any?,BasicAnim: boolean?,CustomElasped: number?,CustomDirection: boolean?,CustomProgBefore: number?)
    local InfoExists = Info ~= nil;
    if Property == nil or Property == EmptyString then return end;
    local Banned = Storage.TweenserviceBanned[PropertyType]
    if Banned or (InfoExists and Info.Frequency ~= nil) then
        --| for complex data types
        local newObject = {
            To = Goal;
            Elapsed = CustomElasped or 0;
            Direction = CustomDirection or true;
            PropertyType = PropertyType;
            ProgBefore = CustomProgBefore or nil;
            RepeatsLeft = (InfoExists and Info.RepeatCount) or 0;
            Delete = Delete;
            Reverse = (InfoExists and Info.Reverse) or nil;
            Time = (InfoExists and Info.Time) or 1;
            Entity = Instance;
            IsValue = IsValue;
            Property = Property;
            DelayTime = (InfoExists and Info.DelayTime) or 0;
            Multiplier = Storage.Multipliers[PropertyType];
            IsBasic = BasicAnim;
        }
        if Info == nil then
            newObject.EasingStyle = DefaultEasingStyle
            newObject.EasingDirection = DefaultEasingDirection
        else
            if Info[easingStyleTxt] then
                newObject.EasingStyle = Info.EasingStyle
                newObject.EasingDirection = Info.EasingDirection or DefaultEasingDirection
            else
                newObject.Frequency = Info.Frequency or 1;
                newObject.Damping = Info.Damping or .25;
            end
        end
        if BasicAnim == nil and Others ~= nil then
            newObject.Others = Others;
            for x = 1,newObject.Others.Count do
                if Initial ~= nil then
                    newObject.Others[x].Entity[newObject.Others[x].Property] = Initial;
                end
                newObject.Others[x].Default = newObject.Initial or newObject.Others[x].Entity[newObject.Others[x].Property]
                newObject.Others[x].Lerp = Lerps[newObject.Others[x].PropertyType](newObject.Others[x].Default,Goal)
            end
        end
        if Initial ~= nil then
            newObject.Initial = Initial;
            Instance[Property] = Initial;
        end

        if BasicAnim and Property ~= nil then
            --< load animation format
            newObject.Lerp = {};
            local Counter = 1;
            for i,v in pairs(Goal) do
                newObject.Lerp[Counter] = {[1] = i, [2] = Lerps[typeof(v)](newObject.Entity[i],v)}
                Counter += 1;
            end
            --> load animation format
        else
            newObject.Default = newObject.Initial or newObject.Entity[newObject.Property]
            newObject.Lerp = Lerps[newObject.PropertyType](newObject.Default,Goal)
        end
        OverlapFixer.Add(Instance,Property,Delete)
        if Storage.Ids == nil then
            Storage.Ids = {};
        end
        Utility.tins(Storage.Ids,Id)
        if Storage.Holder == nil then
            Storage.Holder = {};
        end
        Storage.Holder[Id] = newObject
        if Storage.Count == 0 then
            Storage.Count = 1;
            Storage.Step = RunService.PreRender:Connect(update)
        else
            Storage.Count += 1;
        end
        InfoExists = nil;
        --|
    else
        --| tweenservice
        local Time,EasingStyle,EasingDirection,RepeatCount,Reverse,DelayTime = 
            1,DefaultEasingStyle,DefaultEasingDirection,0,false,0
        if InfoExists == true then
            Time = Info.Time or Time; EasingStyle = Info.EasingStyle or EasingStyle; EasingDirection = Info.EasingDirection or EasingDirection; RepeatCount = Info.RepeatCount or RepeatCount;
            Reverse = Info.Reverse or Reverse; DelayTime = Info.DelayTime or DelayTime
        end
        local Info = TweenInfo.new(
            Time,EasingStyle,EasingDirection,RepeatCount,Reverse,DelayTime
        )
        local Tween = Tweenservice:Create(Instance,Info, (BasicAnim and Goal) or {[Property] = Goal});
        local Connection = Tween.Completed:Connect(function(playbackState)
            if (Storage ~= nil and Storage.RegularTweenHolder ~= nil and Storage.RegularTweenHolder[Id] ~= nil) or BasicAnim then
                if IsValue then
                    Delete(true,true)
                else
                    Delete(true)
                end
            end;
        end)
        OverlapFixer.Add(Instance,Property,Delete)
        if BasicAnim then return Tween,Connection end; -- basic tween
        if Storage.RegularTweenHolder == nil then
            Storage.RegularTweenHolder = {};
        end
        if Initial ~= nil then
            Instance[Property] = Initial;
        end
        Storage.RegularTweenCount += 1;
        Storage.RegularTweenHolder[Id] = {Info = Info,To = Goal,Initial = Initial,Delete = Delete,IsValue = IsValue, Property = Property};
        Storage.RegularTweenHolder[Id].Main = Tween
        Storage.RegularTweenHolder[Id].Main:Play()

        if Others ~= nil then
            Storage.RegularTweenHolder[Id].Others = {Count = 0};
            for i = 1,Others.Count do
                if Others[i] ~= nil then
                    if Initial ~= nil then
                        Others[i].Entity[Property] = Initial;
                    end
                    Storage.RegularTweenHolder[Id].Others[i] = {Main = Tweenservice:Create(Others[i].Entity,Storage.RegularTweenHolder[Id].Info,{[Others[i].Property] = Goal}), Property = Others[i].Property}
                    Storage.RegularTweenHolder[Id].Others[i].Main:Play()
                    Storage.RegularTweenHolder[Id].Others.Count = i;
                end
            end
        end
        Storage.RegularTweenHolder[Id].Connection = Connection
    end
end
function  m.Remove(Id: string)
   if Id == nil then return end;
   
   if Storage.Holder ~= nil and Storage.Holder[Id] ~= nil then
    local Anim = Storage.Holder[Id]
    Storage.Holder[Id] = nil;
    OverlapFixer.Remove(Anim.Entity,Anim.Property)
    Utility.TableRemove(Storage.Ids,Id)
    if Anim.AnimLog then
        Utility.tc(Anim.AnimLog)
        Anim.AnimLog = nil;
    end
    Utility.tc(Anim)
    Storage.Count -= 1;
    if Storage.Count == 0 and Storage.Step ~= nil then
        Storage.Holder = nil;
        Storage.Ids = nil;
        Storage.Step:Disconnect()
    end
    return true
   elseif Storage.RegularTweenHolder ~= nil and Storage.RegularTweenHolder[Id] ~= nil then
        local Anim = Storage.RegularTweenHolder[Id];
        OverlapFixer.Remove(Anim.Main.Instance,Anim.Property)
        Storage.RegularTweenHolder[Id] = nil;
        Anim.Main:Cancel()
        if Anim.Others ~= nil then
            for i = Anim.Others.Count,1,-1 do
                Anim.Others[i].Main:Cancel()
                Anim.Others[i] = nil;
            end
            Anim.Others.Count = nil;
            Anim.Others = nil;
        end
        Anim.Connection:Disconnect()
        Utility.tc(Anim)
        Storage.RegularTweenCount -= 1;
        if Storage.RegularTweenCount == 0 then
            Storage.RegularTweenHolder = nil;
        end
        return true;
   end
end
return m;