local mt = {}
mt.__index = mt;
local tins,tr,tf = table.insert,table.remove,table.find
local disconnectmt = {};
disconnectmt.__index = disconnectmt;
function disconnectmt:Disconnect()
    if self.signal ~= nil then
        local f = tf(self.signal,self);
        if f ~= nil then
            tr(self.signal,f)
        end
        f = nil;
    end
    self.func = nil;
    self.signal = nil;
    setmetatable(self,nil);
end
disconnectmt.Destroy = disconnectmt.Disconnect
--Connect
function mt:Connect(func: () -> ())
    if self.Destroying == true then return end;
    local t = setmetatable({func = func,signal = self},disconnectmt)
    tins(self,t)
    return t;
end
function mt:Once(func: () -> ())
    if self.Destroying == true then return end;
    local t = setmetatable({func = func,signal = self,Once = true},disconnectmt)
    tins(self,t)
    return t;
end
--Destroy
function mt:Destroy()
    if self.Destroying then return end;
    self.Destroying = true;
    self:DisconnectAll();
    setmetatable(self,nil);
    self.Destroying = nil;
end
function mt:DisconnectAll()
    for i = #self,1,-1 do
        self[i]:Disconnect();
        self[i] = nil;
    end
end
 
--Firing signal
function mt:Fire(...)
    for i = #self,1,-1 do
        task.spawn(self[i].func,...)
        if self[i].Once == true then
            self[i]:Disconnect();
        end
    end
end
export type Connection = {
    Disconnect: (self: Connection) -> ();
    Destroy: (self: Connection) -> ();
}
export type Signal = {
    Fire: (self: Signal) -> (),
    Connect: (self: Signal, func: () -> ()) -> Connection,
    Once: (self: Signal, func: () -> ()) -> Connection,
    DisconnectAll: (self: Signal) -> (),
    Destroy: (self: Signal) -> ()
}
return {
    new = function() : Signal
        return setmetatable({},mt) :: any
    end
}