local function getIndex(tab, value)
    for k, v in pairs(tab) do
        if value == v then
            return k
        end
    end
    return nil;
end
local function CountContent(tab)
    local count = 0;
    for i = 1,#tab do
        if tab[i] == nil then break end;
        count += 1
    end
    return count
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
    number = Rep;
    Vector3 = Rep;
    Vector2 = Rep;
    UDim2 = Rep;
    UDim = Rep;
    table = {
        Add = function(tab, Index, Value)
            if Index == nil then return end
            local val = tab.Value
            if Value == nil then
                local Count = CountContent(val)+1;
                val[Count] = Index;
                tab.Changed:Fire(Count, Index, 1)
            else
                val[Index] = Value
                tab.Changed:Fire(Index, Value, 1)
            end
        end,
        Remove = function(tab, Index)
            if Index == nil then return end
            local val = tab.Value
            if val[Index] == nil then
                local pos = getIndex(val, Index)
                if pos ~= nil then
                    val[pos] = nil
                    tab.Changed:Fire(pos, Index, 2) 
                end 
            else
                local Value = val[Index]
                val[Index] = nil
                tab.Changed:Fire(Index, Value, 2)
                Value = nil;
            end
        end
    }
}