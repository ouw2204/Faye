local Types = require(script.Parent.Types)
local ModifyAnimation = require(script.Parent.ModifyAnimation)
return function (Animaiton: {any: any},Modifications: Types.AnimationModifications)
    if Animaiton == nil or Modifications ==nil then return end;
    Animaiton = table.clone(Animaiton) -- clone the animation to not modify the original
    Animaiton.From = Modifications.From;
    Animaiton.AlwaysFrom = Modifications.AlwaysFrom;
    Animaiton.FirstGoal = Modifications.FirstGoal;
    Animaiton.FirstInfo = Modifications.FirstInfo;
    Animaiton.FirstGoal = Modifications.FirstGoal;
    return Animaiton
end