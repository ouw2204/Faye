local tf, tins, tr = table.find, table.insert, table.remove

local function getIndex(tab, value)
    for k, v in pairs(tab) do
        if value == v then
            return k
        end
    end
    return nil;
end

return {
    number = {
        Add = function(tab, value)
            tab.Value += value
            return tab
        end,
        Remove = function(tab, value)
            tab.Value -= value
            return tab
        end
    },
    table = {
        Add = function(tab, Index, Value)
            if Index == nil then return end
            
            local val = tab.Value
            if Value == nil then
                tins(val, Index)
                tab.Changed:Fire(#val, Index, 1)
            else
                val[Index] = Value
                tab.Changed:Fire(Index, Value, 1)
            end
        end,
        Remove = function(tab, Index)
            if Index == nil then return end
            local val = tab.Value
            if val[Index] == nil then
                local pos = tf(val, Index)
                if pos ~= nil then
                    tr(val, pos)
                    tab.Changed:Fire(pos, Index, 2)
                else
                    pos = getIndex(val, Index)
                    if pos ~= nil then
                        tab.Changed:Fire(pos, Index, 2)
                        val[pos] = nil
                    end
                end
            else
                tab.Changed:Fire(Index, val[Index], 2)
                val[Index] = nil
            end
        end
    }
}