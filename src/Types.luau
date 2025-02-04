local m = {}
local Types = require(script.Parent.Misc.OtherTypes)
function m.Thread(Entity)
    return Entity :: Types.ThreaderType;
end
function m.Info(Entity)
    return Entity :: Types.Info
end
function m.SpringInfo(Entity)
    return Entity :: Types.SpringInfo
end
function m.Value(Entity)
    return Entity :: Types.Value
end
function m.Input(Entity)
    return Entity :: Types.UserInputType;
end
return m;