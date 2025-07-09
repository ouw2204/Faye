local tf,tr,tins = table.find,table.remove,table.insert
local tof = typeof
local RunService = game:GetService("RunService")
local RunConnection = (RunService:IsServer() and RunService.Heartbeat) or RunService.RenderStepped
local ValueClasses = require(script.Parent.Parent.Misc.ValueClasses);
local Tweenservice = game:GetService("TweenService")
local Lerps = require(script.Parent.Lerps)
local Spring = require(script.Parent.Spring)
local max = math.max;
local Segment = require(script.Parent.Segment);
local Types = require(script.Parent.Parent.Types)

function isValue(Goal)
    if Goal ~= nil and tof(Goal) == "table" and Goal.__type ~= nil and ValueClasses[Goal.__type] then
        return true;
    end
    return false
end

local AnimsHandler = {
    Holder = {};
    Count = 0;
}
function AnimsHandler.Update(delta)
    for i = 1,AnimsHandler.Count do
        local Anim = AnimsHandler.Holder[i];
        if Anim == nil then continue end;
        if Anim.Time == nil or Anim.DelayTime == nil then if Anim["Stop"] ~= nil then Anim:Stop() else AnimsHandler:Remove(Anim) end; continue end;
        if Anim.Ran == false then
            warn(` was stopped due to a error in its previous run. - {debug.traceback()}`)
            Anim:Stop();
            continue;
        end
        Anim.Ran = false;
        Anim.Elapsed = (Anim.Elapsed and Anim.Elapsed+delta) or delta
        local Prog = max( ((Anim.Elapsed) % (Anim.Time+Anim.DelayTime))-Anim.DelayTime,0)
        local NatureProg = Prog
        local MaxProg = 1;
        if Anim.direction == false then
            MaxProg = 0;
            Prog = Anim.Time-Prog;
        end
        Prog /= Anim.Time;
        local EndReached = nil;
        local Pivot = MaxProg;
        if Anim.ProgBefore ~= nil and NatureProg < Anim.ProgBefore then
            if Anim.Reverse == true and Anim.direction == true then
                Anim.direction = false;
            else
                if Anim.repeatleft == 0 then
                    EndReached = true;
                elseif Anim.repeatleft >=1 then
                    Anim.repeatleft -=1
                    Anim.direction = true;
                else
                    Anim.direction = true;
                end
            end
        else
            --Animate
            if Anim.typeIndex == 1 then
                Pivot =  Tweenservice:GetValue(Prog,Anim.easingstyle,Anim.easingdirection) --Anim.Function(Prog)
            elseif Anim.typeIndex == 2 then
                Pivot = Spring(Prog,Anim.Frequency,Anim.Damping)
            end
            --set
        end
        if Pivot ~= nil and Anim.Entity ~= nil and Anim.Entity.Parent ~= nil and Anim.Property ~= nil then
            if Anim.propertyType == "number" then
                Anim.Entity[Anim.Property] = Anim.Default+ ((Anim.To-Anim.Default)*Pivot);
            elseif Lerps[Anim.propertyType] ~= nil then
                Anim.Entity[Anim.Property] = Lerps[Anim.propertyType](Anim.Default,Anim.To)(Pivot)
            else
                warn(`There's no tween support for {Anim.propertyType} property type.`)
                if isValue(Anim.Goal) then
                    Anim:Stop();
                else
                    Anim:Destroy()
                end
            end
        end;
        if EndReached then
            if isValue(Anim.Goal) then
                Anim:Stop();
            else
                Anim:Destroy()
            end
            EndReached = nil;
            MaxProg = nil;
            Pivot = nil;
            continue
        end
        EndReached = nil;
        MaxProg = nil;
        Pivot = nil;
        Anim.ProgBefore = NatureProg;
        Anim.Ran = true;
    end
end
function AnimsHandler:Add(AnimSpawner: Types.Animation,To: any,Entity: Instance, Property: string)
    if AnimSpawner == nil or To == nil or Entity == nil or Instance == nil or Property == nil then return end;
    if AnimSpawner.Animations ~= nil then
        print("clean because nil")
        self:RemoveAll(AnimSpawner);
    end

    local Anim = Segment(Entity,Property)
    --< set props
    Anim.To = To
    Anim.ProgBefore = nil;
    Anim.Entity = nil;
    Anim.Property = nil;
    if Anim.Default == nil then
        Anim.Default = Entity[Property]

        if Anim.Initial ~= nil and tof(Anim.Initial) == tof(Anim.__Default) then
            Anim.Default = Anim.Initial;
            Entity[Anim.Property] = Anim.Initial;
            if Anim.DontResetInitial == nil then
                Anim.Initial = nil;
            end
        end
           
    end
    if Anim.propertyType == nil then
        Anim.propertyType = tof(Anim.Default);
    end
    Anim.direction = true;
    Anim.repeatleft = Anim.__RepeatCount;
    Anim.Ran = true;
    --> set props

    tins(self.Holder,Anim);
    tins(AnimsHandler.Animations,Anim)
    AnimsHandler.Count += 1;
    if self.Count == 0 then
        self.SteppedConnection = RunConnection:Connect(self.Update)
    end
    self.Count += 1;
end
function AnimsHandler:Remove(AnimSpawner: Types.Animation, Anim: any)
    if Anim == nil then return end;
    local pos = tf(self.Holder,Anim);
    Anim:Destroy();
    if pos ~= nil then
        tr(self.Holder,pos)
        print("destroy")
        if self.Count-1 <= 0 then
            self.Count = 0;
            if self.SteppedConnection ~= nil then
                self.SteppedConnection:Disconnect();
                self.SteppedConnection = nil;
            end
        elseif self.Count >0 then
            self.Count -= 1;
        end
        return true;
    end
    return false;
end
function  AnimsHandler:RemoveAll(AnimSpawner: Types.Animation)
    for i = AnimsHandler.AnimationsAmount,1,-1 do
        self:Remove(AnimSpawner,AnimsHandler.Animations[i])
    end
    print(AnimSpawner," is anim spawner after complete")
    AnimSpawner.Animations = nil;
end
return AnimsHandler;