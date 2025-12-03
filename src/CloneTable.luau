local Utility = require(script.Parent.Misc.FayeUtility)
--[=[
    @function CloneTable
    @within Thread
    @param Table {any:any}
    @param cloneFunction (Index: any, Value: any) -> (any?, any?)?
    @return {any:any}?
    Clones a table. If a cloneFunction is provided, it will be used to determine how to clone each entry.
]=]
return function (Table: {any: any}, cloneFunction: (Index: any, Value: any) -> (any?, any?)?)
    if Table == nil or Utility.tof(Table) ~= Utility.tabletxt then return end;
    if cloneFunction ~= nil then
        local new = {};
        for i,v in pairs(Table) do
            local newindex,newvalue = cloneFunction(i,v)
            if newindex ~= nil then
                if newvalue ==nil then
                    new[i] = newindex;
                else
                    new[newindex] = newvalue;
                end
            else
                new[i] = nil;
            end
        end
        return new;
    else
        return table.clone(Table)
    end
end