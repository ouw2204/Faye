local Types = require(script.Parent.Types)
local Storage = require(script.Parent.Compile.Compilers.CompileAnimations.Player.AnimatorStorage)
local OverlapFixer = require(script.Parent.Compile.Compilers.CompileAnimations.Player.OverlapFixer)
local AnimPlayer = require(script.Parent.Compile.Compilers.CompileAnimations.Player)
local Info = require(script.Parent.Info)
local prefix = "PlayedAnimation_"
local IdCount = 0;
local DefaultInfo = Info()
local Utility = require(script.Parent.Misc.FayeUtility)

local mt = {};
mt.__index = mt
function mt:Play(Elapsed: number?,Direction: boolean?,ProgBefore: number?)
    self:Stop(nil,true); -- stop any previous animation
    local DeleteFunc =  function(_,_,FromStop: boolean)
        
        if self.Anim ~= nil then
            self:Stop(); -- regular anims don't save a delete function so if this is fired is to stop the anim
        else
            AnimPlayer.Remove(self.__id)
            self.DeleteFunc = nil;
            if FromStop then return end;
            self:Stop() -- since this call is not from the stop function we want to call the stop function
        end
    end
    local Anim,Connection = AnimPlayer.Add(
        self.__id,
        self.To,
        self.Info,
        DeleteFunc,
        self.Entity,
        self.Property,
        nil, -- Others
        nil, -- IsValue
        nil, -- PropertyType
        nil, -- Initial
        true, -- BasicAnim
        Elapsed,Direction,ProgBefore
    )
    if Anim ~= nil then
        DeleteFunc = nil; -- we don't need it anymore
        self.Connection = Connection
        self.Anim = Anim
        self.Anim:Play()
    else
        self.DeleteFunc = DeleteFunc;
        DeleteFunc = nil;
    end
    return self;
end
function mt:Skip()
    -- Set the property to the goal value immediately
    for i,v in pairs(self.To) do
        self.Entity[i] = v;
    end
    -- Clean up the animation like Stop does
    if self.Anim ~= nil then
        if self.Anim.PlaybackState == Enum.PlaybackState.Playing then
            self.Connection:Disconnect()
            self.Connection = nil;
            self.Anim:Cancel();
            self.Anim = nil;
        end;
        OverlapFixer.Remove(self.Entity,self.Property) -- remove from storage
    elseif self.DeleteFunc ~= nil then
        self.DeleteFunc(nil,nil,true) -- send nils to clear the anim;
        self.DeleteFunc = nil;
    end
    
    -- Clear state
    self.Elapsed = nil;
    self.Direction = nil;
    self.ProgBefore = nil;
    
    -- Destroy the animation
    self:Destroy(true)
    
    return self;
end
function mt:Stop(NoClear: boolean?,CameFromPlay: boolean?)
    if self.Anim ~= nil then
        if NoClear then return end;
        if self.Anim.PlaybackState == Enum.PlaybackState.Playing then
            self.Connection:Disconnect()
            self.Connection = nil;
            self.Anim:Cancel();
            self.Anim = nil;
        end;
        OverlapFixer.Remove(self.Entity,self.Property) -- remove from storage
    elseif self.DeleteFunc ~= nil then
        self.DeleteFunc(nil,nil,true) -- send nils to clear the anim;
        self.DeleteFunc = nil;
    end
    if NoClear then return end;
    self.Elapsed = nil;
    self.Direction = nil;
    self.ProgBefore = nil;
    if CameFromPlay == nil then
        self:Destroy(true) -- destroy the animation
    end
end
function mt:Pause()
    if self.Anim ~= nil then
        self.Anim:Pause();
    else
        local AnimFetched = Storage.Holder[self.__id]
        
        self.ProgBefore = AnimFetched.ProgBefore
        self.Elapsed = AnimFetched.Elapsed
        self.Direction = AnimFetched.Direction
        self:Stop(true) -- clear the anim
    end
    return self;
end
function mt:Resume()
    if self.Anim ~= nil then
        self.Anim:Play();
    else
        self:Play(self.Elapsed,self.Direction,self.ProgBefore)
    end
    return self;
end
function mt:Destroy(CameFromStop: boolean?)
    if CameFromStop == nil then -- if this is not called from the stop function
        self:Stop();
    end
    if self.Thread ~= nil then
        Utility.RemoveFromThread(self.Thread,self)
    end
    Utility.tc(self);
    setmetatable(self,nil)
end

return function(Entity: Instance,Goal: Types.Properties,Info: (Types.Info | Types.SpringInfo)?, Thread: Types.Thread): Types.PlayableAnimation
    if Entity == nil or Goal == nil  or Utility.tof(Goal) ~= Utility.tabletxt then warn("Was unable to create animation, check the parameters and retry!") return end;
    if Info == nil then Info = DefaultInfo end;
    if Entity.ClassName == nil then
        Entity = Entity.Instance;
        if Entity.ClassName == nil then warn("Entity must be a roblox instance or faye instance"); return end;
    end
    local Property = "";
    for i,_ in pairs(Goal) do
        Property ..= i;
    end
    local Animation = {Entity = Entity,To = Goal, Property = Property, Info = Info,__id = prefix..IdCount, Thread = Thread};
    
    setmetatable(Animation, mt)
    IdCount += 1;
    if Thread ~= nil then
        Utility.AddToThread(Thread,Animation)
    end
    return Animation
end