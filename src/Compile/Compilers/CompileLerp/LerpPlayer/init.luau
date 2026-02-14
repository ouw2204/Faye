local RunService = game:GetService("RunService")
local FayeUtility = require(script.Parent.Parent.Parent.Parent.Misc.FayeUtility)


local m = {
    Holder = {
        Indexes = {};
        Anims = {};
    };
    Count = 0;
};

function updateFunction()
    for _,v in ipairs(m.Holder.Indexes) do
        
        local Anim = m.Holder.Anims[v]
        if Anim.Last == false then
            m.Remove(v)
            continue
        end
        Anim.Last = false;
        if Anim.Entity ~= nil and Anim.Entity.Parent ~= nil  then
            local before = Anim.Entity[Anim.Property]
            Anim.Entity[Anim.Property] = before:Lerp(Anim.To,Anim.Factor);
            local allDone = Anim.Entity[Anim.Property] == before
            if Anim.Workers then
                for i = Anim.Workers.Count, 1, -1 do
                    local worker = Anim.Workers[i]
                    if worker.Entity == nil or worker.Entity.Parent == nil then
                        table.remove(Anim.Workers, i)
                        Anim.Workers.Count -= 1
                    else
                        local wBefore = worker.Entity[worker.Property]
                        worker.Entity[worker.Property] = wBefore:Lerp(Anim.To,Anim.Factor);
                        if worker.Entity[worker.Property] ~= wBefore then
                            allDone = false
                        end
                    end
                end
            end
            if allDone then
                if Anim.IsValue then
                    Anim.Delete(true);
                else
                    Anim.Delete();
                end
                continue
            end
        else
           Anim.Delete();
           continue
        end
        Anim.Last = true;
    end
end

function m.Add(id: string, Entity: Instance,Index: string,To: any,Factor: number,IsValue: boolean,Delete,Workers: {{Entity: Instance, Property: string}}?)
    local Anim = m.Holder.Anims[id]
    if Anim then
        Anim.To = To
        return
    end
    table.insert(m.Holder.Indexes,id)
    m.Holder.Anims[id] = {
        Entity = Entity;
        Property = Index;
        Factor = Factor;
        To = To;
        Last = true;
        IsValue = IsValue;
        Workers = Workers;
        Delete = Delete;
    }
    m.Count += 1;
    if m.Count == 1 then
        m.Connection = RunService.PreRender:Connect(updateFunction)
    end
end
function m.Find(id)
    local index = FayeUtility.tf(m.Holder.Indexes,id)
    return index,m.Holder.Anims[id];
end
function m.Remove(id)
    local index = m.Find(id)
    if index ~= nil then
        FayeUtility.tr(m.Holder.Indexes,index)
        m.Count -= 1;
        if m.Count == 0 then
            if m.Connection ~= nil then
                m.Connection:Disconnect();
                m.Connection = nil;
            end
        end
        m.Holder.Anims[id] = nil;
    end
end

return m;