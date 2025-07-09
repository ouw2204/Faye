local tins,tf,tr = table.insert,table.find,table.remove
local function getIndex(tab, value)
    for k, v in pairs(tab) do
        if value == v then
            return k
        end
    end
    return nil;
end
local Rep = {
    Add = function(tab, value)
		tab.Value += value
		tab.Changed:Fire(tab.Value)
        return tab
    end;
    Remove = function(tab, value)
		tab.Value -= value
		tab.Changed:Fire(tab.Value)
        return tab
    end;
}
return {
    number = {
        Add = function(tab, value)
            tab.Value += value
            tab.Changed:Fire(tab.Value, value,nil,1)
            return tab
        end;
        Remove = function(tab, value)
            tab.Value -= value
            tab.Changed:Fire(tab.Value,value,nil,2)
            return tab
        end;
    };
    Vector3 = Rep;
    Vector2 = Rep;
    UDim2 = Rep;
    UDim = Rep;
    table = {
        Add = function(tab, Index, Value)
            if Index == nil then return end
            local val = tab.Value
            if Value == nil then
                tins(val,Index)
                tab.Changed:Fire(val,tf(val,Index), Index, 1,true)
            else
                val[Index] = Value
                tab.Changed:Fire(val,Index, Value, 1)
            end
        end,
        Remove = function(tab, Index)
            if Index == nil then return end
            local val = tab.Value
            if val[Index] == nil then
                local f = tf(val,Index)
                if f ~= nil then
                    tr(val,f)
                    tab.Changed:Fire(val,f, Index, 2,true)
                else
                    local pos = getIndex(val, Index)
                    if pos ~= nil then
                        val[pos] = nil
                        tab.Changed:Fire(val,pos, Index, 2) 
                    end
                end
            else
                local Value = val[Index]
                val[Index] = nil
                tab.Changed:Fire(val,Index, Value, 2)
                Value = nil;
            end
        end
    }
}