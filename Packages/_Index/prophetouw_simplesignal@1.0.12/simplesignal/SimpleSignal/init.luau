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
        if self[i] == nil then continue end;
        self[i]:Disconnect();
        self[i] = nil;
    end
end
 
--Firing signal
function mt:Fire(...)
    for i = #self,1,-1 do
        local v = self[i];
        if v == nil then continue end;
        task.spawn(v.func,...)
        if v.Once == true then
            v:Disconnect();
        end
    end
end

function mt:Wait(timeout: number)
    local thread = coroutine.running()
    local isFired = false
    local connection
    local timeoutTask = nil  -- Variable to hold the reference to the timeout task

    connection = self:Connect(function(...)
        if not isFired then
            isFired = true
            connection:Disconnect()
            if timeoutTask then
                task.cancel(timeoutTask)
                timeoutTask = nil;
            end
            coroutine.resume(thread, ...)
        end
    end)

    if timeout then
        timeoutTask = task.delay(timeout, function()
            if not isFired then
                isFired = true
                connection:Disconnect()
                coroutine.resume(thread, nil) -- Resume with nil to indicate a timeout
            end
        end)
    end

    return coroutine.yield()
end

export type Connection = {
    Disconnect: (self: Connection) -> ();
    Destroy: (self: Connection) -> ();
}
export type Signal = {
    Fire: (self: Signal, ...any) -> (),
    Connect: (self: Signal, func: () -> ()) -> Connection,
    Once: (self: Signal, func: () -> ()) -> Connection,
    DisconnectAll: (self: Signal) -> (),
    Destroy: (self: Signal) -> (),
    Wait: (self: Signal, timeout: number) -> any
}
return {
    new = function() : Signal
        return setmetatable({},mt) :: any
    end
}