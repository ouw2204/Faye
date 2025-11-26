local Types = require(script.Parent.Types)
--[=[
    @method ModifyAnimation
    @within Thread
    @param Animaiton {any: any}
    @param Modifications Types.AnimationModifications
    @return ModifyAnimation
]=]
return function (Animaiton: {any: any},Modifications: Types.AnimationModifications)
    if Animaiton == nil or Modifications ==nil then return end;
    Animaiton.From = Modifications.From;
    Animaiton.AlwaysFrom = Modifications.AlwaysFrom;
    Animaiton.FirstGoal = Modifications.FirstGoal;
    Animaiton.FirstInfo = Modifications.FirstInfo;
    Animaiton.FirstDelayTime = Modifications.FirstDelayTime;
end