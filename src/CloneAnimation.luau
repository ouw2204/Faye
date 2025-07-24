local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Misc.Utility)
return function (Animaiton: {any: any},Modifications: Types.AnimationModifications,Thread: Types.Thread?)
    if Animaiton == nil then return end;
    Animaiton = table.clone(Animaiton) -- clone the animation to not modify the original
    if Thread ~= nil then
        Animaiton.NoThread = nil;
        Utility.AddToThread(Thread,Animaiton)
    else
        Animaiton.NoThread = true;
    end
    if Modifications == nil then return Animaiton end;
    Animaiton.From = Modifications.From;
    Animaiton.AlwaysFrom = Modifications.AlwaysFrom;
    Animaiton.FirstGoal = Modifications.FirstGoal;
    Animaiton.FirstInfo = Modifications.FirstInfo;
    Animaiton.FirstGoal = Modifications.FirstGoal;
    return Animaiton
end