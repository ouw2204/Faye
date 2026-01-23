local tof = typeof
local destroytxt,tabletxt,cleantxt,instancetxt,functiontxt,rbxlscripttxt,threadtxt = "Destroy","table","Clean","Instance","function","RBXScriptConnection","thread"
return function (Scope: any?,Count: number?)
    for k = Count or #Scope, 1, -1 do
        local v = Scope[k]
        local type = tof(v)
        Scope[k] = nil
        if type == tabletxt then
            if v[destroytxt] ~= nil or v[cleantxt] ~= nil then
                if v.__Destroying then Scope[k] = nil; continue end;
                if v[destroytxt] then
                    v:Destroy()
                elseif v[cleantxt] then
                    v:Clean()
                end
            end
        elseif type == instancetxt then
            v:Destroy()
        elseif type == functiontxt then
            v()
        elseif type == rbxlscripttxt then
            v:Disconnect()
        elseif type == threadtxt then
            task.cancel(v)
        end
    end
end