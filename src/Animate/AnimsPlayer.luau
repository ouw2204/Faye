local tf,tr,tins = table.find,table.remove,table.insert
local tof = typeof
local RunService = game:GetService("RunService")
local RunConnection = (RunService:IsServer() and RunService.Heartbeat) or RunService.RenderStepped
local ValueClasses = require(script.Parent.Parent.Misc.ValueClasses);
local Lerps = require(script.Parent.Lerps)
local Spring = require(script.Parent.Spring)
local max = math.max;
function isValue(Goal)
    if Goal ~= nil and tof(Goal) == "table" and Goal.__type ~= nil and ValueClasses[Goal.__type] then
        return true;
    end
    return false
end

local AnimsHandler = {
    Holder = {};
    Anim = nil;
    Count = 0;
}
function AnimsHandler.Update(delta)
    for i = 1,AnimsHandler.Count do
        local Anim = AnimsHandler.Holder[i];
        if Anim == nil then continue end;

        Anim.Elapsed = (Anim.Elapsed and Anim.Elapsed+delta) or delta
        local Prog = max( ((Anim.Elapsed) % (Anim.Info.Time+Anim.Info.DelayTime))-Anim.Info.DelayTime,0)
        local NatureProg = Prog
        local MaxProg = 1;
        if Anim.__direction == false then
            MaxProg = 0;
            Prog = Anim.Info.Time-Prog;
        end
        Prog /= Anim.Info.Time;
        local EndReached = nil;
        local Pivot = MaxProg;
        if Anim.__ProgBefore ~= nil and NatureProg < Anim.__ProgBefore then
            if Anim.Info.Reverse == true and Anim.__direction == true then
                Anim.__direction = false;
            else
                if Anim.__repeatleft == 0 then
                    EndReached = true;
                elseif Anim.__repeatleft >=1 then
                    Anim.__repeatleft -=1
                    Anim.__direction = true;
                else
                    Anim.__direction = true;
                end
            end
        else
            --Animate
            if Anim.__typeIndex == 1 then
                Pivot =  Anim.Function(Prog)
            elseif Anim.__typeIndex == 2 then
                Pivot = Spring(Prog,Anim.Info.Frequency,Anim.Info.Damping)
            end
            --set
        end
        if Pivot ~= nil and Anim.Entity ~= nil and Anim.Entity.Parent ~= nil and Anim.Property ~= nil then
            if Anim.__propertyType == "number" then
                Anim.Entity[Anim.Property] = Anim.__Default+ ((Anim.__To-Anim.__Default)*Pivot);
            elseif Lerps[Anim.__propertyType] ~= nil then
                Anim.Entity[Anim.Property] = Lerps[Anim.__propertyType](Anim.__Default,Anim.__To)(Pivot)
            else
                warn(`There's no tween support for {Anim.__propertyType} property type.`)
                if isValue(Anim.Goal) then
                    Anim:Stop();
                else
                    Anim:Destroy()
                end

                Anim.__To = nil;
                Anim.__ProgBefore = nil;
                Anim.__direction = nil;
                Anim.__repeatleft = nil;
                Anim.__Default = nil;
                Anim.__propertyType = nil;
            end
        end;
        if EndReached then
            if isValue(Anim.Goal) then
                Anim:Stop();
            else
                Anim:Destroy()
            end

            --
            Anim.__ProgBefore = nil;
            Anim.__direction = nil;
            Anim.__repeatleft = nil;
            Anim.__To = nil;
            Anim.__Default = nil;
            Anim.__propertyType = nil;
        end
        EndReached = nil;
        MaxProg = nil;
        Pivot = nil;
        Anim.__ProgBefore = NatureProg;
    end
end
function AnimsHandler:Add(Anim)
    if Anim == nil then return end;
    if Anim.Animating == true then
        self:Remove(Anim);
    end
    Anim.__ProgBefore = nil;
    if Anim.__Default == nil then
        Anim.__Default = Anim.Entity[Anim.Property]

        if Anim.Initial ~= nil and tof(Anim.Initial == tof(Anim.__Default)) then
            Anim.__Default = Anim.Initial;
            Anim.Initial = nil;
        end
           
    end
    if Anim.__propertyType == nil then
        Anim.__propertyType = tof(Anim.__Default);
    end
    Anim.__direction = true;
    Anim.__repeatleft = Anim.Info.RepeatCount;
    Anim.Animating = true;
    
    tins(self.Holder,Anim);
    if self.Count == 0 then
        self.Anim = RunConnection:Connect(self.Update)
    end
    self.Count += 1;
end
function AnimsHandler:Remove(Anim)
    if Anim == nil then return end;
    local pos = tf(self.Holder,Anim);
    if pos ~= nil then
        tr(self.Holder,pos)


        Anim.__ProgBefore = nil;
        Anim.__direction = nil;
        Anim.__repeatleft = nil;
        Anim.__Default = nil;
        Anim.__propertyType = nil;


        if self.Count-1 <= 0 then
            self.Count = 0;
            if self.Anim ~= nil then
                self.Anim:Disconnect();
                self.Anim = nil;
            end
        elseif self.Count >0 then
            self.Count -= 1;
        end
    end
    Anim.Animating = nil;
    
end
return AnimsHandler;