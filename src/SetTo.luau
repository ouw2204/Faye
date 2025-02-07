local tof = typeof
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local tc = table.clear
local tr,tf = table.remove,table.find
local tins = table.insert
local types = require(script.Parent.Types)

local mt = {}
mt.__index = mt;
function mt:Destroy()
    if self.Thread ~= nil then
        if self.Thread["Remove"] ~= nil then
            self.Thread:Remove(self)
        else
            local position = tf(self.Thread,self)
            if position ~= nil then
                tr(self.Thread,position)
            end
        end
    end
    tc(self)
end

return function(Value: any,Thread: types.Thread) : any
    if Value == nil or tof(Value) ~= "table" or Value.__type == nil or ValueClasses[Value.__type] == nil then warn(`Pass a valid value object - {debug.traceback()}`); return end;
    local new = {
        __type = script.Name;
        Value = Value;
        Thread = Thread;
    };
    setmetatable(new,mt)
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(new)
        else
            tins(Thread,new)
        end
    end
    return new;
end
