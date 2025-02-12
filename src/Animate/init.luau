local tc = table.clear
local tof = typeof
local OtherTypes = require(script.Parent.Types)
local RunService = game:GetService("RunService")
local RunConnection = (RunService:IsServer() and RunService.Heartbeat) or RunService.RenderStepped
local ValueClasses = require(script.Parent.Misc.ValueClasses);
local Lerps = require(script.Lerps)
local Spring = require(script.Spring)
local mt = {}
mt.__index = mt;
local Functions = require(script.Functions)

--math
max = math.max

function mt:UpdateInfo(Info)
    if Info == nil then return end;
    if Info.__typeIndex == 1 then
        self.Function = Functions[Info.EasingStyle.Name][Info.EasingDirection.Name]
    else
        self.Function = nil;
    end
    self.__typeIndex = Info.__typeIndex;
    self.Info = Info;
end
function mt:Destroy()
    self:Stop();
    self.Goal = nil;
    self.Thread = nil;
    self.Entity = nil;
    self.Property = nil;
    self.Initial = nil;
    if self.Info ~= nil then
        tc(self.Info)
    end
    self.Info = nil;
    self.RenderFunction = nil;
    self.Function = nil;
    tc(self)
end
function mt:Stop()
    if self.RenderFunction ~= nil then
        self.RenderFunction:Disconnect();
        self.RenderFunction = nil;
    end
    self.Elapsed = nil;
end
function mt:Skip()
    self.SkipFirstValue = true;
    return self;
end
function isValue(Goal)
    if Goal ~= nil and tof(Goal) == "table" and Goal.__type ~= nil and ValueClasses[Goal.__type] then
        return true;
    end
    return false
end
function mt:Play(To: any)
   if To == nil then return end;
   if self.RenderFunction ~= nil then
    self.RenderFunction:Disconnect();
    self.RenderFunction = nil;
   end
   if self.Info == nil then warn(`Info is missing - {debug.traceback()}`); return end;
   if self.Entity == nil or self.Property == nil then warn(`Entity or property is missing - {debug.traceback}`); return end;

   -- variables setup
   local Through = true;
   local ProgBefore = nil;
   local direction = true;
   local repeatleft = self.Info.RepeatCount;
   local Default = self.Entity[self.Property]
   if self.Initial ~= nil and tof(self.Initial == tof(Default)) then
    Default = self.Initial;
   end
   local propertyType = tof(Default)
   --loop connection
   self.RenderFunction = RunConnection:Connect(function(delta)
    if self.Entity == nil or self.Property == nil or self.Info == nil then self:Destroy();
    --
    Through = nil;
    ProgBefore = nil;
    direction = nil;
    repeatleft = nil;
    Default = nil;
    propertyType = nil;
    return end;
    if Through == false then
        --Errored
        self.RenderFunction:Disconnect()
        self.RenderFunction = nil;
        self:Destroy()


        --
        Through = nil;
        ProgBefore = nil;
        direction = nil;
        repeatleft = nil;
        Default = nil;
        propertyType = nil;
        return
    end
    Through = false;
    self.Elapsed = (self.Elapsed and self.Elapsed+delta) or delta
    local Prog = max( ((self.Elapsed) % (self.Info.Time+self.Info.DelayTime))-self.Info.DelayTime,0)
    local NatureProg = Prog
    if direction == false then
        Prog = self.Info.Time-Prog;
    end
    Prog /= self.Info.Time;
    --Apply info
    local Pivot = nil;
    if ProgBefore ~= nil and NatureProg < ProgBefore then
        if self.Info.Reverse == true and direction == true then
            direction = false;
        else
            if repeatleft == 0 then
                if isValue(self.Goal) then
                    self:Stop();
                else
                    self:Destroy()
                end

                --
                Through = nil;
                ProgBefore = nil;
                direction = nil;
                repeatleft = nil;
                Default = nil;
                propertyType = nil;
            elseif repeatleft >=1 then
                repeatleft -=1
                direction = true;
            else
                direction = true;
            end
        end
    else
        --Animate
        if self.__typeIndex == 1 then
            Pivot =  self.Function(Prog)
        elseif propertyType ~= "number" and self.__typeIndex == 2 then
            Pivot = Spring(Prog,self.Info.Frequency,self.Info.Damping)
        end
        --set
    end
    if Pivot ~= nil and self.Entity ~= nil and self.Entity.Parent ~= nil and self.Property ~= nil then
        if propertyType == "number" then
            self.Entity[self.Property] = Default+ ((To-Default)*Pivot);
        elseif Lerps[propertyType] ~= nil then
            self.Entity[self.Property] = Lerps[propertyType](Default,To)(Pivot)
        else
            warn(`There's no tween support for {propertyType} property type.`)
            self.RenderFunction:Disconnect()
            if isValue(self.Goal) then
                self:Stop();
            else
                self:Destroy()
            end
            --
            Through = nil;
            ProgBefore = nil;
            direction = nil;
            repeatleft = nil;
            Default = nil;
            propertyType = nil;
            Pivot = nil;
        end
    end;
    --Keeping track of last value to trigger ending
    ProgBefore = NatureProg;
    Through = true;
end)
end
function mt:From(Value: any)
    if Value == nil then warn(`Must pass a from value - {debug.traceback()}`); return end;
    self.Initial = Value;
    return self;
end
return function(Goal: any,Info: OtherTypes.Info | OtherTypes.SpringInfo,Thread: OtherTypes.Thread?) : OtherTypes.AnimationType
    local new = {
        __type = script.Name;
        Goal = Goal;
        Thread = Thread;
        Entity = nil;
        Property = nil;
        Info = Info;
    }
    setmetatable(new,mt)
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            table.insert(Thread,new)
        end
    end
    return new :: any;
end
