local Types = require(script.Parent.Parent.Parent.Types)
return function (Entity: Types.FayeInstance, Index: any, Value: Types.Value)
    print(Entity,Index,Value)
end