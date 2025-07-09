
local ThreadType = require(script.Parent.Types)

--[=[
    @method Info
    @within Thread
    @param Time number?
    @param EasingStyle Enum.EasingStyle?
    @param EasingDirection Enum.EasingDirection?
    @param RepeatCount number?
    @param Reverse boolean?
    @param DelayTime number?
    @return Info
    Creates a new Info object with the given parameters.
]=]
return function(Time: number?,EasingStyle: Enum.EasingStyle?,EasingDirection: Enum.EasingDirection?, RepeatCount: number?,Reverse: boolean?,DelayTime: number?)
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
