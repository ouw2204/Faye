local tof = typeof
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local tc = table.clear
local tr,tf = table.remove,table.find
local tins = table.insert
local types = require(script.Parent.Misc.OtherTypes)
return function(Value: any,Thread: types.ThreadType) : any
    if Value == nil or tof(Value) ~= "table" or Value.__type == nil or ValueClasses[Value.__type] == nil then warn(`Pass a valid value object - {debug.traceback()}`); return end;
    local new = {
        __type = script.Name;
        Value = Value;
    };
    function new:Destroy()
        if Thread ~= nil then
            if Thread["Remove"] ~= nil then
                Thread:Remove(new)
            else
                local position = tf(Thread,new)
                if position ~= nil then
                    tr(Thread,position)
                end
            end
        end
        tc(self)
    end
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new;
end
