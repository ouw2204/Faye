local Types = require(script.Parent.FayeTypes)
local Storage = require(script.Parent.Compile.Compilers.CompileAnimations.Player.AnimatorStorage)
local OverlapFixer = require(script.Parent.Compile.Compilers.CompileAnimations.Player.OverlapFixer)
local AnimPlayer = require(script.Parent.Compile.Compilers.CompileAnimations.Player)
local Info = require(script.Parent.Info)
local prefix = "PlayedAnimation_"
local IdCount = 0;
local DefaultInfo = Info()
local Utility = require(script.Parent.Misc.FayeUtility)
--[=[
    @method LoadAnimation
    @within Thread
    @param Entity Instance -- The instance to animate
    @param Goal Types.Properties -- The goal properties to animate to
    @param Info Types.Info? -- (Optional) The animation info
    return LoadAnimation -- The playable animation object
]=]
local mt = {};
mt.__index = mt
--[=[
    @class LoadAnimation
    Quick animation loader that creates and plays an animation on an entity.
]=]

--[=[
    @method Play
    @within LoadAnimation
    Plays the animation.
]=]
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
--[=[
    @method Skip
    @within LoadAnimation
    Skips the animation to the end state immediately.
]=]
function mt:Skip()
    -- Set the property to the goal value immediately
    for i,v in pairs(self.To) do
        self.Entity[i] = v;
    end
    -- Clean up the animation like Stop does
    if self.Anim ~= nil then
        if self.Anim.PlaybackState == Enum.PlaybackState.Playing then
            self.Anim:Cancel();
            self.Anim = nil;
        end;
        if self.Connection ~= nil then
            self.Connection:Disconnect()
            self.Connection = nil;
        end
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
--[=[
    @method Stop
    @within LoadAnimation
    Stops the animation.
]=]
function mt:Stop(NoClear: boolean?,CameFromPlay: boolean?)
    if self.Anim ~= nil then
        if NoClear then return end;
        if self.Anim.PlaybackState == Enum.PlaybackState.Playing then
            self.Anim:Cancel();
            self.Anim = nil;
        end;
        if self.Connection ~= nil then
            self.Connection:Disconnect()
            self.Connection = nil;
        end
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
--[=[
    @method Pause
    @within LoadAnimation
    Pauses the animation.
]=]
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
--[=[
    @method Resume
    @within LoadAnimation
    Resumes the animation from where it was paused.
]=]
function mt:Resume()
    if self.Anim ~= nil then
        self.Anim:Play();
    else
        self:Play(self.Elapsed,self.Direction,self.ProgBefore)
    end
    return self;
end
--[=[
    @method Destroy
    @within LoadAnimation
    Destroys the animation object and cleans up resources.
]=]
function mt:Destroy(CameFromStop: boolean?)
    if CameFromStop == nil then -- if this is not called from the stop function
        self:Stop();
    end
    if self.Thread ~= nil then
        Utility.RemoveFromThread(self.Thread,self)
    end

end

return function(Entity: Instance,Goals: Types.Properties,Info: (Types.Info | Types.SpringInfo)?, Thread: Types.Thread): Types.LoadAnimation
    if Entity == nil or Goals == nil  or Utility.tof(Goals) ~= Utility.tabletxt then warn("Was unable to create animation, check the parameters and retry!") return end;
    if Info == nil then Info = DefaultInfo end;
    if Entity.ClassName == nil then
        Entity = Entity.Instance;
        if Entity.ClassName == nil then warn("Entity must be a roblox instance or faye instance"); return end;
    end
    local Property = "";
    for i,_ in pairs(Goals) do
        Property ..= i;
    end
    local Animation = {Entity = Entity,To = Goals,IsActive = true, Property = Property, Info = Info,__id = prefix..IdCount, Thread = Thread};
    
    setmetatable(Animation, mt)
    IdCount += 1;
    if Thread ~= nil then
        Utility.AddToThread(Thread,Animation)
    end
    return Animation
end