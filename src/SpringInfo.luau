local tc= table.clear
local tr,tf = table.remove,table.find
local tins = table.insert
local OtherTypes = require(script.Parent.Misc.OtherTypes)
return function(Time: number,Frequency: number,Damping: number, RepeatCount: number,Reverse: boolean,DelayTime: number,Thread: OtherTypes.ThreadType)
    local new = {
        __typeIndex = 2;
        Time = Time or 1;
        Frequency = Frequency or 1;
        Damping = Damping or .2;
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
    return new :: OtherTypes.SpringInfo
end
