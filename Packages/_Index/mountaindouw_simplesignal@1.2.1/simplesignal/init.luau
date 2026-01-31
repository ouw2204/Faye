local mt = {}
mt.__index = mt;
local st = "Simple Signal"
mt.__tostring = function()
    return st
end
local tins,tr,tf = table.insert,table.remove,table.find
local disconnectmt = {__simplesignalconnection = true};
disconnectmt.__index = disconnectmt;
local st2 = "Simple Signal Connection"
disconnectmt.__tostring = function()
    return st2
end
function disconnectmt:Disconnect()
    if self.signal ~= nil then
        local f = tf(self.signal,self);
        if f ~= nil then
            tr(self.signal,f)
        end
        f = nil;
    end
    if self.lists ~= nil then
        local find = tf(self.lists,self);
        if find ~= nil then
            tr(self.lists,find);
        end
        self.lists = nil;
    end
    self.__simplesignalconnection = nil;
    self.func = nil;
    self.signal = nil;
end
disconnectmt.Destroy = disconnectmt.Disconnect
--Connect
function mt:Connect(func: () -> (),RemoveFromTableOnDisconnect: {[any]: any}?)
    if self.Destroying == true then return end;
    local t = setmetatable({func = func,signal = self},disconnectmt)
    tins(self,t)
    if self.Queu ~= nil then
        for i = #self.Queu,1,-1 do
            local v = self.Queu[i];
            self:Fire(table.unpack(v));
            self.Queu[i] = nil;
        end
        table.clear(self.Queu)
        self.Queu = nil;
    end
    if RemoveFromTableOnDisconnect ~= nil then
        if t.lists == nil then
            t.lists = RemoveFromTableOnDisconnect;
        end
        
    end
    return t;
end
function mt:Once(func: () -> ())
    if self.Destroying == true then return end;
    local t; t = setmetatable({func = function(...)
        func(...)
        t:Disconnect()
    end,signal = self,Once = true},disconnectmt)
    tins(self,t)
    return t;
end
--Destroy
function mt:Destroy()
    if self.Destroying then return end;
    self.Destroying = true;
    self:DisconnectAll();
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
local cur;
local cr,cy,cc = coroutine.resume,coroutine.yield,coroutine.create
local perform = function(func,...)

    if func == nil then
        return true
    else
        local currentcur = cur;
        cur = nil;
        func(...)
        if cur == nil then
            cur = currentcur;
            return
        else
            return true
        end
    end

end
local runner = function()
    while true do
        if perform(cy()) then break end;
    end
end
local zerocheck = 0;
local increment = 1;
local caller = error
function mt:Fire(...)
    
    local i = #self;
    while i >zerocheck do
        local v = self[i];
        if v == nil then continue end;
        if cur == nil then
            cur = task.spawn(runner)
        end
        local er,m = cr(cur,v.func,...)
       
        if not er then
            cur = nil;
            task.spawn(caller,`Simple Signal Errored while firing: {m} - {debug.traceback()}`)
        end
        i -=increment
    end
end
-- no task.spawn
function mt:BasicFire(...)
    local i = #self;
    while i >zerocheck do
        local v = self[i]
        if v == nil then
            continue
        end
        v.func(...)
        if v.Once == true and v.Disconnect then
            v:Disconnect()
        end
        i -= increment
    end
end
--queus and waits for connections
function mt:SafeFire(...)
    if #self > 0 then
        task.defer(self.BasicFire, self, ...)
    else
        if self.Queu == nil then
            self.Queu = {}
        end
        table.insert(self.Queu, { ... })
    end
end

function mt:Wait(timeout: number?)
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
            cr(thread, ...)
        end
    end)

    if timeout then
        timeoutTask = task.delay(timeout, function()
            if not isFired then
                isFired = true
                connection:Disconnect()
                cr(thread, nil) -- Resume with nil to indicate a timeout
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
    BasicFire: (self: Signal, ...any) -> (),
    SafeFire: (self: Signal, ...any) -> ();
    Connect: (self: Signal, func: (...any) -> (),RemoveFromTableOnDisconnect: {[any]: any}?) -> Connection,
    Once: (self: Signal, func: (...any) -> ()) -> Connection,
    DisconnectAll: (self: Signal) -> (),
    Destroy: (self: Signal) -> (),
    Wait: (self: Signal, timeout: number?) -> any
}
return {
    new = function() : Signal
        return setmetatable({},mt) :: any
    end
}