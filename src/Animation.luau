local Types = require(script.Parent.FayeTypes)
local Utility = require(script.Parent.Misc.FayeUtility)
local typetxt,idtxt = "Animation","Anim_"
local counter = 0;
local Modify = require(script.Parent.ModifyAnimation);
local mt = {}
mt.__index = mt;
local Storage = require(script.Parent.Compile.Compilers.CompileAnimations.Player.AnimatorStorage)
--[=[
    @class Animation
    Represents an animation object that can be played on an entity.
]=]
--[=[
    @method Animation
    @within Thread
    @param Goal any -- The target value or state for the animation
    @param Info Types.Info | Types.SpringInfo? -- (Optional) The animation info
    @param Modifications Types.AnimationModifications? -- (Optional) Modifications to apply to the animation
    @return Animation
    Creates an animation object with the specified goal, info, and optional modifications.
]=]

--[=[
    @method Destroy
    @within Animation
    Cleans up the animation object and removes it from any associated threads.
]=]
function mt:Destroy()
    if self.__animId then
        local fetch = (Storage.RegularTweenHolder ~= nil and Storage.RegularTweenHolder[self.__animId]) or (Storage.Holder ~= nil and Storage.Holder[self.__animId]) or nil
        if fetch ~= nil then
            fetch.Delete();
        end
    end
    if self.Thread ~= nil then
        Utility.RemoveFromThread(self.Thread,self)
    end
end
--[=[
    @method Stop
    @within Animation
    Stops the animation if it is currently playing.
]=]
function mt:Stop()
    if self.__animId == nil then return end;
    local fetch = (Storage.RegularTweenHolder ~= nil and Storage.RegularTweenHolder[self.__animId]) or (Storage.Holder ~= nil and Storage.Holder[self.__animId]) or nil
    
    if fetch ~= nil then
        if fetch.IsValue then
            fetch.Delete(true,true)
        else
            fetch.Delete(true);
        end
    end
end
--[=[
    @method Skip
    @within Animation
    Immediately applies the animation's goal state to the target entity.
]=]
function mt:Skip()
    if self.__animId == nil then return end;
    local fetch = (Storage.RegularTweenHolder ~= nil and Storage.RegularTweenHolder[self.__animId]) or (Storage.Holder ~= nil and Storage.Holder[self.__animId]) or nil
    if fetch == nil then
        return;
    end
    local Goal,Entity,Property = fetch.To,fetch.Entity,fetch.Property;
    
    if Goal ~= nil then
        if fetch.Main ~= nil then
            Entity = fetch.Main.Instance;
            if fetch.Others ~= nil then
                for _,v in ipairs(fetch.Others) do
                    v.Main.Instance[v.Property] = Goal
                end
            end
        else
            if fetch.Others ~= nil then
                for _,v in ipairs(fetch.Others) do
                    v.Entity[v.Property] = Goal
                end
            end
        end

        if Entity ~= nil and Property ~= nil then
            Entity[Property] = Goal
        end
    end
    if fetch ~= nil then
        if fetch.IsValue then
            fetch.Delete(true,true)
        else
            fetch.Delete(true);
        end
    end
end
return function(Goal: any,Info: (Types.Info | Types.SpringInfo)?,Modifications: Types.AnimationModifications?,Thread: Types.Thread?): Types.Animation
    local new = {Goal = Goal, Info = Info, __type = typetxt,__animId = idtxt..counter};
    if Thread == nil then
        new.NoThread = true;
    end
    counter += 1;
    if Modifications ~= nil then
        Modify(new,Modifications)
    end
    setmetatable(new,mt)
    if Thread ~= nil and Thread.__Destroying == nil then
        new.Thread = Thread;
        Utility.AddToThread(Thread,new)
    elseif Thread ~= nil then
        new.DestroyOnClean = true;
    end
    return new;
end