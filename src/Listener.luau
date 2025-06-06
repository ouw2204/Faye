local tof = typeof

--[=[
    @method Listener
    @within Thread
    @param Entity any
    @param Event(s) any
    @param Function function
    @param Thread any?
    Connects the given function to the specified event(s) on the entity.
]=]
return function(Entity: any, Event: any,Function: (any: any) -> (),Thread) : ()
    if Entity == nil or Event == nil or Function == nil then return end;
    if tof(Event) ~= "table" then
        Thread:Connect(Entity[Event],function(...)
            Function(Event,...)
        end)
    else
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
    
end
