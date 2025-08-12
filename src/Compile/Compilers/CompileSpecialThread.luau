local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)

type SpecialThread = {
    func: (Thread: Types.Thread, Entity: Instance) -> ();
    Params: Types.SpecialThreadParams;
}
return function (Instance: Types.FayeInstance,Index, SpecialThread: SpecialThread,Compile)
    local ParentThread: Types.Thread = Instance.InnerThread or Instance.Thread;
    if ParentThread == nil then return end;
    local NewThread = ParentThread:Extend(true)
    print(SpecialThread)
    local res1,res2 = SpecialThread.func(NewThread,Instance.Instance)
    local Delete; Delete = function(remove)
        if remove then
            if EqThread ~= nil then
                print("remove")
                Utility.RemoveFromThread(EqThread,Delete)
            else
                print("AAAAA")
            end
        else
            print("threaed remove")
        end
        if NewThread ~= nil and NewThread.IsActive then
            print("is ac")
            NewThread:Destroy();
            NewThread = nil;
        end

    end
    local Entity = {Instance = Instance.Instance, Thread = NewThread}
    if res1 ~= nil then
        if Index ~= nil and Utility.tof(Index) ~= Utility.numbertxt then
            Compile(Entity,{[Index] = res1},NewThread)
        else
            if res2 ~= nil then
                Compile(Entity,{[res1] = res2},NewThread)
            else
                Compile(Entity, (Utility.tof(res1) == Utility.tabletxt and res1.__type == nil and res1) or {res1} ,NewThread)
            end
        end
    else
        --[[Utility.CallDestroy(Eq.Thread)
        Eq.Thread = nil;]]
        Delete(true)
    end
    if Utility.tof(SpecialThread.Params) == Utility.numbertxt then
        ParentThread:Delay(SpecialThread.Params,Delete,true)
    else
        if SpecialThread.Params.Lifetime ~= nil then
            ParentThread:Delay(SpecialThread.Params.Lifetime,Delete,true)
        end
    end
    if ParentThread ~= nil then
        EqThread = ParentThread;
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
        print("Add tp ",EqThread,EqThread == NewThread,NewThread)
        EqThread:Add(function()
            print("REMOVEE")
        end)
        Utility.AddToThread(EqThread,Delete)
    end
end