local Types = require(script.Parent.Types)
local tins = table.insert
local tf,tr = table.find,table.remove
local tc = table.clear
return function(Tab: {any: any},Func: (Index: any,Value: any,InnerThread: Types.Thread?,Entity: Instance?) -> (),Thread: Types.Thread)
    if Tab == nil or Func == nil then return end;

    local new = {
        __type = script.Name;
        Function = Func;
        Tab = Tab;
        Thread = Thread;
    };
    function new:Destroy()
        if self.Thread ~= nil then
            if self.Thread["Remove"] then
                self.Thread:Remove(self)
            else
                local f = tf(self.Thread,self)
                if f ~= nil then
                    tr(self.Thread,f)
                end
            end
        end
        self.Tab = nil;
        self.Function = nil;
        tc(self)
    end
    function new:Get()
        local New = {}
        for i,v in pairs(self.Tab) do
            local Index,Value = Func(i,v)
            if Value == nil then
                tins(New,Index)
            else
                new[Index] = Value;
            end
        end
        return New;
    end
    if Thread ~= nil then
        if Thread["Add"] ~= nil then
            Thread:Add(new)
        else
            tins(Thread,new);
        end
    end
    return new;
end
