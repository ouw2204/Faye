local Utility = require(script.Parent.Misc.Utility)
local Types = require(script.Parent.Types)
--[=[
    @method Listener
    @within Thread
    @param Entity any
    @param Event(s) any
    @param Function function
    @param Thread any?
    Connects the given function to the specified event(s) on the entity.
]=]

return function(Entity: any, Event: any,Function: (any: any) -> (),Thread: Types.Thread) : ()
    if Entity == nil or Event == nil or Function == nil then return end;
    if Utility.tof(Event) ~= "table" then
        Utility.Connect(Entity[Event],function(...)
            Function(Event,...)
        end,Thread)
    else
        for _,v in ipairs(Event) do
            Utility.Connect(Entity[v],function(...)
                Function(v,...)
            end,Thread)
        end
    end
end
