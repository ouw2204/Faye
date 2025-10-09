local Storage =require(script.Parent.AnimatorStorage)

local m = {};

function m.Add(Entity: Instance, Property: string, Delete: () -> ())
    if Storage.Active[Entity] ~= nil and Storage.Active[Entity][Property] ~= nil then
        local fetch = Storage.Active[Entity][Property]
        Storage.Active[Entity][Property] = nil;
        Storage.Active[Entity].Count -= 1;
        fetch(); -- remove previous animation on this property
    end
    if Storage.Active[Entity] == nil then Storage.Active[Entity] = {Count = 0} end;
    Storage.Active[Entity].Count += 1;
    Storage.Active[Entity][Property] = Delete;
end
function m.Remove(Entity: Instance, Property: string)
    local t = Storage.Active[Entity]
    if not t then return end
    if t[Property] ~= nil then
        t[Property] = nil
        t.Count -= 1
    end
    if t.Count <= 0 then
        Storage.Active[Entity] = nil
    end
end
 
return m;