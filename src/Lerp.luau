local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local FayeTypes = require(script.Parent.FayeTypes)
local LerpPlayer = require(script.Parent.Compile.Compilers.CompileLerp.LerpPlayer)

local mt = {__type = script.Name};
mt.__index = mt;

function mt:Skip()
    local _, Anim = LerpPlayer.Find(self.__lerpid)
    if Anim then
        Anim.Entity[Anim.Property] = Anim.To
        if Anim.Workers then
            for i = 1, Anim.Workers.Count do
                local worker = Anim.Workers[i]
                if worker.Entity ~= nil and worker.Entity.Parent ~= nil then
                    worker.Entity[worker.Property] = Anim.To
                end
            end
        end
        LerpPlayer.Remove(self.__lerpid)
    end
end
function mt:Stop()
    LerpPlayer.Remove(self.__lerpid)
end
function mt:Destroy()
    self:Stop()
    if self.Thread ~= nil then
        FayeUtility.RemoveFromThread(self.Thread,self)
    end
end

local nameString = script.Name;
local Counter = 0;
return function(Value: any, Factor: number, From: any?, Thread: FayeTypes.Thread)
    local new = setmetatable({To = Value, Factor = Factor or .15, From = From, Thread = Thread, __lerpid = nameString..Counter},mt)
    Counter += 1;
    if Thread ~= nil then
        FayeUtility.AddToThread(Thread,new)
    end
    return new
end
