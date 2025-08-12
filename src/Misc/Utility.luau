local m = {tof = typeof,max = math.max, tr = table.remove, tf = table.find, tins = table.insert,tc = table.clear,

tabletxt = "table",numbertxt = "number",instanceTxt = "Instance",valueBaseTxt = "ValueBase",functiontxt = "function"}
local Types = require(script.Parent.Parent.Types)
local Clean = require(script.Parent.Parent.Clean)
function m.RemoveFromThread(Thread: Types.Thread, Item: any)
    if Thread == nil or Item == nil then return end;
    if Thread["Remove"] then
        Thread:Remove(Item)
    else
        local f = m.tf(Thread,Item)
        if f ~= nil then
            m.tr(Thread,f)
        end
    end
end
function m.Connect(Signal: RBXScriptSignal,Function: (...any) -> (),Thread: Types.Thread?)
    if Signal == nil or Function == nil then return end;
    local Connect = Signal:Connect(Function)
    if Thread ~= nil then
        if Thread["Connect"] then
            Thread:Connect(Signal,Function)
        elseif Thread["Add"] then
            Thread:Add(Connect)
        else
            m.tins(Thread,Connect)
        end
    end
end
function m.CallDestroy(Item: any)
    if Item == nil then return end;
    if Item["Destroy"] then
        Item:Destroy();
    else
        local Count = #Item
        if Count <= 0 then return end;
        Clean(Item,Count)
    end
end
function m.TableRemove(Table: {any: any}, Item: any)
    if Table == nil or Item == nil then return end;
    local f = m.tf(Table,Item)
    if f ~= nil then
        m.tr(Table,f)
    end
    f = nil;
end
function  m.AddToThread(Thread: Types.Thread, Item: any)
    if Thread["Add"] then
        Thread:Add(Item)
    else
        m.tins(Thread,Item)
    end
end
local disconnecttxt = "Disconnect"
function m.ClearAllConnections(Connections: {[number]: RBXScriptConnection},connectionsNumb: number)
    for i = connectionsNumb or #Connections,1,-1 do
        if Connections[i] ~= nil and Connections[i][disconnecttxt] ~= nil then
            Connections[i]:Disconnect();
        end
        Connections[i] = nil;
    end
end
local ValueClasses = require(script.Parent.ValueClasses)
function m.GetValue(Info: Types.Value)
    if Info == nil then return end;
    if Info.__type ~= nil and ValueClasses[Info.__type] then
        return m.GetValue(Info:Get())
    else
        return Info
    end
end
return m;