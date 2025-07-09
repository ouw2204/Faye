local mt = {};
mt.__index = mt;

function  mt:Destroy()
    self.Entity = nil;
    self.Property = nil;
    setmetatable(self,nil)
    print(self," is segment after deletion")
end

return function (Entity: Instance, Property: string)
    if Entity == nil or Property == nil then return end;
    return setmetatable({
        Entity = Entity;
        Property = Property;
    },mt)
end