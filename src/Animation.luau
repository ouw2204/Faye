local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
local typetxt,idtxt = "Animation","Anim_"
local counter = 0;
local Modify = require(script.Parent.ModifyAnimation);
return function(Goal: any,Info: (Types.Info | Types.SpringInfo)?,Modifications: Types.AnimationModifications?,Thread: Types.Thread?): Types.Animation
    print(Thread.__Destroying," ADDDDDDDDDDDDDDDDDDDDDDDDDD")
    local new = {Goal = Goal, Info = Info, __type = typetxt,__animId = idtxt..counter};
    if Thread == nil then
        new.NoThread = true;
    end
    counter += 1;
    if Modifications ~= nil then
        Modify(new,Modifications)
    end
    if Thread ~= nil and Thread.__Destroying == nil then
        Utility.AddToThread(Thread,new)
    elseif Thread~= nil then
        new.DestroyOnClean = true;
    end
    return new;
end