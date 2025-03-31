local tof = typeof

--[=[
    @method Event
    @within Thread
    @param Entity any
    @param Event(s) any
    @param Function function
    @param Thread any?
    [Connects the given function to the specified event(s) on the entity.](/docs/Utilities/Event)
]=]
return function(Entity: any, Event: any,Function: (any: any) -> (),Thread) : ()
    if Entity == nil or Event == nil or Function == nil then return end;
    if tof(Event) ~= "table" then
        Event = {Event}
    end
    for i,v in pairs(Event) do
        if Thread ~= nil then
            Thread:Connect(Entity[v],function(...)
                Function(v,...)
            end)
        else
            Entity[v]:Connect(function(...)
                Function(v,...)
            end)
        end
    end
end
