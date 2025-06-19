local m = {}
local Types = require(script.Parent.Parent.Types)
local tr,tf,tins = table.remove, table.find,table.insert
function m.RemoveFromThread(Thread: Types.Thread, Item: any)
    if Thread == nil or Item == nil then return end;
    if Thread["Remove"] then
        Thread:Remove(Item)
    else
        local f = tf(Thread,Item)
        if f ~= nil then
            tr(Thread,f)
        end
    end
end
function  m.AddToThread(Thread: Types.Thread, Item: any)
    if Thread["Add"] then
        Thread:Add(Item)
    else
        tins(Thread,Item)
    end
end
function m.ClearAllConnections(Connections: {[number]: RBXScriptConnection},connectionsNumb: number)
    for i = connectionsNumb or #Connections,1,-1 do
        if Connections[i]["Disconnect"] ~= nil then
            Connections[i]:Disconnect();
         end;
         Connections[i] = nil;
    end
end
return m;