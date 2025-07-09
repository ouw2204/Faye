local Types = require(script.Parent.Parent.Types)
local tf,tr,tins = table.find,table.remove,table.insert
local tof = typeof
local RunService = game:GetService("RunService")
local RunConnection = (RunService:IsServer() and RunService.Heartbeat) or RunService.RenderStepped
local ValueClasses = require(script.Parent.Parent.Misc.ValueClasses);
local Tweenservice = game:GetService("TweenService")
local Lerps = require(script.Parent.Lerps)
local Spring = require(script.Parent.Spring)
local max = math.max;

local m = {
    Count = 0;
}

local mt = {};
mt.__index = mt;
function isValue(Goal)
    if Goal ~= nil and tof(Goal) == "table" and Goal.__type ~= nil and ValueClasses[Goal.__type] then
        return true;
    end
    return false
end
function mt:InnerDestroy()
    self.__ProgBefore = nil;
    self.__repeatleft = nil;
    self.__Ran = nil;
    self.__propertyType = nil;
    self.__To = nil;
    self.__direction = nil;
    self.Elapsed = nil;
    self.Entity = nil;
    self.Property = nil;
    self.__Default = nil;
    setmetatable(self,nil)
end

function  m.Update(delta)
    for i = 1,m.Count do
        local Anim = m[i];
        if Anim == nil then continue end;
        if Anim.__Time == nil or Anim.__DelayTime == nil then if Anim["Stop"] ~= nil then Anim:Stop() else m:Remove(Anim) end; continue end;
        if Anim.__Anim.__Ran == false then
            warn(` was stopped due to a error in its previous run. - {debug.traceback()}`)
            Anim:Stop();
            continue;
        end
        Anim.__Anim.__Ran = false;
        Anim.__Anim.Elapsed += delta
        local Prog = max( ((Anim.__Anim.Elapsed) % (Anim.__Time+Anim.__DelayTime))-Anim.__DelayTime,0)
        local NatureProg = Prog
        local MaxProg = 1;
        if Anim.__Anim.__direction == false then
            MaxProg = 0;
            Prog = Anim.__Time-Prog;
        end
        Prog /= Anim.__Time;
        local EndReached = nil;
        local Pivot = MaxProg;
        if Anim.__Anim.__ProgBefore ~= nil and NatureProg < Anim.__Anim.__ProgBefore then
            if Anim.__Reverse == true and Anim.__Anim.__direction == true then
                Anim.__Anim.__direction = false;
            else
                if Anim.__Anim.__repeatleft == 0 then
                    EndReached = true;
                elseif Anim.__Anim.__repeatleft >=1 then
                    Anim.__Anim.__repeatleft -=1
                    Anim.__Anim.__direction = true;
                else
                    Anim.__Anim.__direction = true;
                end
            end
        else
            --Animate
            if Anim.__typeIndex == 1 then
                Pivot =  Tweenservice:GetValue(Prog,Anim.__easingstyle,Anim.__easingdirection) --Anim.Function(Prog)
            elseif Anim.__typeIndex == 2 then
                Pivot = Spring(Prog,Anim.__Frequency,Anim.__Damping)
            end
            --set
        end
        if Pivot ~= nil and Anim.__Anim.Entity ~= nil and Anim.__Anim.Entity.Parent ~= nil and Anim.__Anim.Property ~= nil then
            if Anim.__Anim.__propertyType == "number" then
                Anim.__Anim.Entity[Anim.__Anim.Property] = Anim.__Anim.__Default+ ((Anim.__Anim.__To-Anim.__Anim.__Default)*Pivot);
            elseif Lerps[Anim.__Anim.__propertyType] ~= nil then
                Anim.__Anim.Entity[Anim.__Anim.Property] = Lerps[Anim.__Anim.__propertyType](Anim.__Anim.__Default,Anim.__Anim.__To)(Pivot)
            else
                warn(`There's no tween support for {Anim.__Anim.__propertyType} property type.`)
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
        Anim.__Anim.__ProgBefore = NatureProg;
        Anim.__Anim.__Ran = true;
    end
end
function m.Add(Anim: Types.Animation,To: any,Entity: Instance, Property: string,Default: any, PropertyType: string)
    if Anim == nil or To == nil or Entity == nil or Property == nil or PropertyType == nil then return end;
    m:Remove(Anim);
    if Anim.Initial ~= nil and tof(Anim.Initial) == PropertyType then
        Entity[Property] = Anim.Initial;
        Default = Anim.Initial;
        if Anim.DontResetInitial == nil then
            Anim.Initial = nil;
        end
    end
    Anim.__Anim = setmetatable({
        __ProgBefore = nil;
        __direction = true;
        Entity = Entity;
        Property = Property;
        Elapsed = 0;
        __Default = Default;
        __repeatleft = Anim.__RepeatCount;
        __Ran = true;
        __propertyType = PropertyType;
        __To = To;
    },mt)

    tins(m,Anim);
    if m.Count == 0 then
        m.Step = RunConnection:Connect(m.Update)
    end
    m.Count += 1;
end
function  m.Remove(Anim: Types.Animation)
    if Anim == nil then return end;
    local pos = tf(m,Anim);
    if pos ~= nil then
        tr(m,pos)
        --< remove anim
        Anim.__Anim:InnerDestroy();
        Anim.__Anim = nil;
        --> 
        if m.Count-1 <= 0 then
            m.Count = 0;
            if m.Step ~= nil then
                m.Step:Disconnect();
                m.Step = nil;
            end
        elseif m.Count >0 then
            m.Count -= 1;
        end
        return true;
    end
    return false;
end
return m;