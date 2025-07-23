local Types = require(script.Parent.Types)

return function (Animaiton: {any: any},Modifications: Types.AnimationModifications)
    if Animaiton == nil or Modifications ==nil then return end;
    Animaiton.From = Modifications.From;
    Animaiton.AlwaysFrom = Modifications.AlwaysFrom;
    Animaiton.FirstGoal = Modifications.FirstGoal;
    Animaiton.FirstInfo = Modifications.FirstInfo;
    Animaiton.FirstGoal = Modifications.FirstGoal;
end