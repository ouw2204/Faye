local Types = require(script.Parent.Types)
local tins,tf,tr = table.insert,table.find,table.remove
local mt = {__type = script.Name}
mt.__index = mt;
--[=[
    @class AttributeChanged
    For Attribute changed signals
]=]
--[=[
    @method Destroy
    @within AttributeChanged
    Destroy function
]=]
function mt:Destroy()
    if self.Thread["Remove"] then
        self.Thread:Remove(self)
    else
        local f = tf(self.Thread,self)
        if f ~= nil then
            tr(self.Thread,f)
        end
    end
    self.Thread = nil;
    self.Method = nil;
    self.Index = nil;
    setmetatable(self,nil)
end
--[=[
    @method AttributeChanged
    @within Thread
    @param Attribute string
    @param Thread any?
    @return AttributeChanged
    Attribute changed listener
]=]
return function (Method: string,Index: string, Thread: Types.Thread?)
    if Method == nil or Index == nil then return end;
    local d = {Method = Method,Index = Index,Thread = Thread};
    setmetatable(d,mt)
    if Thread ~= nil then
        if Thread["Add"] then
            Thread:Add(d)
        else
            tins(Thread,d)
        end
    end
    return d;
end