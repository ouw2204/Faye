local OtherTypes = require(script.Parent.Types)

--[=[
    @method SpringInfo
    @within Thread
    @param Time number?
    @param Frequency number?
    @param Damping number?
    @param RepeatCount number?
    @param Reverse boolean?
    @param DelayTime number?
    @return SpringInfo
]=]
return function(Time: number?,Frequency: number?,Damping: number?, RepeatCount: number?,Reverse: boolean?,DelayTime: number?)
    local new = {
        __typeIndex = 2;
        Time = Time or 1;
        Frequency = Frequency or 1;
        Damping = Damping or .2;
        RepeatCount = RepeatCount or 0;
        Reverse = Reverse or false;
        DelayTime = DelayTime or 0
    };
    return new :: OtherTypes.SpringInfo
end
