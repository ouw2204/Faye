local ThreadType = require(script.Parent.Types)
return function(Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number)
    local new = {
        __typeIndex = 1;
        Time = Time or 1;
        EasingStyle = EasingStyle or Enum.EasingStyle.Linear;
        EasingDirection = EasingDirection or Enum.EasingDirection.Out;
        RepeatCount = RepeatCount or 0;
        Reverse = Reverse or false;
        DelayTime = DelayTime or 0
    };
    return new :: ThreadType.Info
end
