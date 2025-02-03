local tc= table.clear
local tr,tf = table.remove,table.find
local tins = table.insert
local ThreadType = require(script.Parent.Misc.OtherTypes)
return function(Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number,Thread: ThreadType.ThreadType?)
    local new = {
        __typeIndex = 1;
        Time = Time or 1;
        EasingStyle = EasingStyle or Enum.EasingStyle.Linear;
        EasingDirection = EasingDirection or Enum.EasingDirection.Out;
        RepeatCount = RepeatCount or 0;
        Reverse = Reverse or false;
        DelayTime = DelayTime or 0
    };
    function new:Destroy()
        if Thread ~= nil then
            if Thread["Remove"] then
                Thread:Remove(new)
            else
                local find = tf(Thread,self)
                if find ~= nil then
                    tr(Thread,find)
                end
            end
        end
        tc(self);
    end
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new :: ThreadType.Info
end
