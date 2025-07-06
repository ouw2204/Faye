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
    self.Attribute = nil;
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
return function (Attribute: string, Thread: Types.Thread?)
    local d = {Attribute = Attribute,Thread = Thread};
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