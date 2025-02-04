Prop = {
    Add = function(Entity,Property,Am)
        Entity[Property] += Am;
    end;
    Remove = function(Entity,Property,Am)
        Entity[Property] -= Am;
    end
}
Attr = {
    Add = function(Entity,Property,Am)
        Entity:SetAttribute(Property,Entity:GetAttribute(Property) + Am);
    end;
    Remove = function(Entity,Property,Am)
        Entity:SetAttribute(Property,Entity:GetAttribute(Property) - Am);
    end
}
StringProp = {
    Add = function(Entity,Property,Am)
        Entity[Property] ..= Am;
    end
}
StringAttribute = {
    Add = function(Entity,Property,Am)
        Entity:SetAttribute(Property,Entity:GetAttribute(Property) .. Am);
    end
}
local m  = {
    Attributes = {
        number = Attr;Vector3 = Attr;Vector2 = Attr;UDim2 = Attr;UDim = Attr; string = StringAttribute;
    };
    Property = {
        number = Prop;Vector3 = Prop;Vector2 = Prop;UDim2 = Prop;UDim = Prop;string = StringProp
    };
}
return m;