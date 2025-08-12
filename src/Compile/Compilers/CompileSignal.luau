local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)


return function (Instance: Types.FayeInstance,Index, Signal: Types.Signal)
    local Thread = Instance.InnerThread or Instance.Thread;
    local Entry = {Instance = Instance, Index = (Utility.tof(Index) ~= Utility.numbertxt and Index) or nil}
    local EqThread
    --local Connection;
    local function  Delete()
        --[[if Connection ~= nil then
            Connection:Disconnect();
            Connection = nil;
        end]]
        --| Remove from thread
        --[[f EqThread ~= nil then
            Utility.RemoveFromThread(Thread,Delete)
        end]]
        --|>

        --| remove from entries
        if Signal ~= nil and Signal.Entries ~= nil then
            local position = Utility.tf(Signal.Entries,Entry)
            if position ~= nil then
                Utility.tr(Signal.Entries,position)
                Signal.Entries.Count -= 1;
                if Signal.Entries.Count == 0 then
                    Signal.Entries.Count = nil;
                    Signal.Entries = nil;
                end
            end
        end
        --|>

        --| Delete entry
        if Entry ~= nil then
            if Entry.Thread ~= nil then
                Utility.CallDestroy(Entry.Thread)
                Entry.Thread = nil;
            end
            Utility.tc(Entry)
            Entry = nil;
        end
        --|>
    end
    --[[Connection = Instance.Instance:GetPropertyChangedSignal("Parent"):Connect(function()
        if Instance.Instance == nil or Instance.Instance.Parent == nil then
            Delete()
        end
    end)]]
    if Signal.Entries == nil then
        Signal.Entries = {Count = 0};
    end
    Signal.Entries[Signal.Entries.Count + 1] = Entry
    Signal.Entries.Count += 1;
    if Thread ~= nil then
        EqThread = Thread;
        if EqThread._isCleanAncestor then
            local CurrentPos = EqThread
            while CurrentPos ~= nil do
                if CurrentPos._hc then
                    break;
                end
                CurrentPos = CurrentPos.ParentThread;
            end
            EqThread = CurrentPos or EqThread;
        end
        Utility.AddToThread(EqThread,Delete)
    end
end