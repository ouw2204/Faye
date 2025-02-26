local tc,tf,tr = table.clear,table.find,table.remove
local OtherTypes = require(script.Parent.Types)
local mt = {
    __type = script.Name;
}
mt.__index = mt;
local Functions = require(script.Functions)
local Cleaner = require(script.Parent.Clean)
--math
max = math.max
local AnimsHandler = require(script.AnimsPlayer);
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
function mt:Destroy(FromStop)
    if FromStop ==nil then
        self:Stop(true);
    end
    if self.Thread then
        if self.Thread["Remove"] then
            self.Thread:Remove(self)
        else
            local Pos = tf(self.Thread,self)
            if Pos then
                tr(self.Thread,Pos)
            end
        end
        self.Thread = nil;
    end
    self.Goal = nil;
    self.Entity = nil;
    self.Property = nil;
    self.Initial = nil;
    if self.Info ~= nil then
        tc(self.Info)
    end
    self.Info = nil;
    self.Function = nil;
    tc(self)
end
function mt:Stop(FromDestroy)
    if self.Thread ~= nil then
        if self.Thread.AnimationsAmount ~= nil and self.Animating then
            self.Thread.AnimationsAmount = math.max(self.Thread.AnimationsAmount - 1, 0)
        end
        if self.Thread.CleanWhenDone and (self.Thread.AnimationsAmount == nil or self.Thread.AnimationsAmount <= 0) then
            self.Thread.CleanWhenDone = nil;
            if FromDestroy == nil then
                self:Destroy(true)
            end
            Cleaner(self.Thread)
        end
    end
    AnimsHandler:Remove(self);
    self.Animating = nil;
    self.Elapsed = nil;
end
function mt:Skip()
    self.SkipFirstValue = true;
    return self;
end
function mt:Play(To: any)
   if To == nil then return end;
   self:Stop();
   if self.Info == nil then warn(`Info is missing - {debug.traceback()}`); return end;
   if self.Entity == nil or self.Property == nil then warn(`Entity or property is missing - {debug.traceback()}`); return end;
   if self.Thread ~= nil then
        self.Thread.AnimationsAmount = (self.Thread.AnimationsAmount or 0) + 1
    end
    self.__To = To;
    AnimsHandler:Add(self);
end
function mt:From(Value: any)
    if Value == nil then warn(`Must pass a from value - {debug.traceback()}`); return end;
    self.Initial = Value;
    return self;
end
return function(Goal: any,Info: OtherTypes.Info | OtherTypes.SpringInfo,Thread: OtherTypes.Thread?) : OtherTypes.AnimationType
    local new = {
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
