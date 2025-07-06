local tf, tins, tr, tof, tc = table.find, table.insert, table.remove, typeof, table.clear
local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
local Types = require(script.Parent.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Parent.Misc.Utility)
local removetxt,extendtxt,cleantxt,addtxt,tabletxt,numbertxt = "Remove","Extend","Clean","Add","table","number"
local function subCompile(Thread: Types.Thread,ActualValue: {Function: (Index: any, Value: any, NewThread: any, Instance: any) -> ()},Entity:  Types.FayeInstance, Holder: {[any]: any},Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> (),Index: any, Value: any, FirstIndex: any)
    if Index == nil or Value == nil then return end
		local EquippedIndex = FirstIndex or Index
		if Thread ~= nil then
			if Holder[EquippedIndex] ~= nil then
				if Thread[removetxt] then
					Thread:Remove(Holder[EquippedIndex])
				else
					local Pos = tf(Thread, Holder[EquippedIndex])
					if Pos ~= nil then
						tr(Thread, Pos)
					end
				end
				Holder[EquippedIndex]:Clean()
				Holder[EquippedIndex] = nil
			end
		end;
		local NewThread = (Thread ~= nil and Thread[extendtxt] ~= nil and Thread:Extend()) or {};
		NewThread._isCleanAncestor = Thread._isCleanAncestor
		local I, V = ActualValue.Function(Index, Value, NewThread, Entity.Instance)
		local NewCompile = {}
		if V == nil then
			tins(NewCompile, I)
		elseif I ~= nil and V ~= nil then
			NewCompile[I] = V
		end
		Holder[EquippedIndex] = NewThread
		Compile(Entity, NewCompile, NewThread)
end
local function  cleanIndividual(Thread: Types.Thread,Holder: {any: any},Index: any)
	if Thread == nil or Holder == nil or Index == nil then return end;
    if Holder[Index] ~= nil then
		Utility.RemoveFromThread(Thread,Holder[Index])
        Holder[Index]:Clean()
        Holder[Index] = nil
    end
end
local function cleanHolder(Thread: Types.Thread,Holder: {[any]: any})
    for i, v in pairs(Holder) do
        if Thread[removetxt] then
            Thread:Remove(v)
        else
            local Pos = tf(Thread, v)
            if Pos then
                tr(Thread, Pos)
            end
        end
        if v ~= nil and v[cleantxt] then
            v:Clean()
        end
    end
    tc(Holder)
end
return function(Entity: Types.FayeInstance, _: string, Value: any, Compile: (Entity: Types.FayeInstance, Props: {[any]: any},...any) -> ())
    local ActualThread: Types.Thread = Entity.Innerthread or Entity.Thread;
    if ActualThread ~= nil and ActualThread ~= Value.Thread then
		if Value.Thread ~= nil then
			if Value.Thread[removetxt] then
				Value.Thread:Remove(Value)
			else
				local f = tf(Value.Thread, Value)
				if f ~= nil then
					tr(Value.Thread, f)
				end
			end
		end
		Value.Thread = ActualThread
		if ActualThread[addtxt] then
			ActualThread:Add(Value)
		else
			tins(ActualThread, Value)
		end
	end
	ActualThread = nil;
    local Holder = {};
	local ConnectionsHolder = {};
	local connectionslength = 0;
	--< main func
	local currentnumber = nil;
    local function mainFunc(Content: Types.Value,Position: number?)
		if Content == nil then return end;
		local ContentType = tof(Content)
		local contentIsNumber = ContentType == numbertxt;
		local contentIsTable = ContentType == tabletxt
		if not contentIsNumber and not contentIsTable then return end;
		Position = Position or 1
		if contentIsNumber then
			cleanHolder(Value.Thread,Holder);
			currentnumber = Content;
			for i = 1,Content do
				subCompile(Value.Thread,Value,Entity,Holder,Compile,i,i)
			end
		else
			if Content.__type ~= nil and ValueClasses[Content.__type] then
				connectionslength = Position;
				ConnectionsHolder[Position] = Content.Changed:Connect(function(__reserved, Index: any, NewValue: any?, ChangeType: number?, IsConventional: boolean?)
					if Index == nil or ChangeType == nil then
						Index = __reserved
					end
					if connectionslength > Position then
						cleanHolder(Value.Thread,Holder);
						for i = connectionslength,Position+1,-1 do
							ConnectionsHolder[i]:Disconnect();
							ConnectionsHolder[i] = nil;
						end
					end
					connectionslength = Position;
					local vType = tof(Index)
					local vtypeisnumber = vType == numbertxt;
					if NewValue == nil and ChangeType == nil then
						mainFunc(Index,Position + 1)
					else
						--< is adds/remove
						if vtypeisnumber and NewValue == nil and ChangeType ~= nil then
							--< numb
							
							if Index >0 then
								local current = currentnumber;
								if ChangeType == 2 then
									currentnumber -= Index;
									for EqIndex = current, math.max(current - Index + 1, 1), -1 do
										if Holder[EqIndex] ~= nil then
											cleanIndividual(Value.Thread,Holder,EqIndex)
										end
									end
								else
									currentnumber += Index;
									for i = 1,Index do
										local final = i + current
										subCompile(Value.Thread,Value,Entity,Holder,Compile, final,final,final)
									end
								end
								current = nil
							end
							--> numb
						else
							--< is something else
							local EqIndex = (IsConventional and NewValue) or Index
							if ChangeType == 2 then
								if Holder[EqIndex] ~= nil then
									cleanIndividual(Value.Thread,Holder,EqIndex)
								elseif Holder[Index] ~= nil then
									cleanIndividual(Value.Thread,Holder,EqIndex)
								end
							else
								subCompile(Value.Thread,Value,Entity,Holder,Compile,Index, NewValue, EqIndex)
							end
							--> is something else
						end
						--> is adds/remove
					end
				end)
				mainFunc(Content:Get(),Position + 1)
			else
				cleanHolder(Value.Thread,Holder);
				for i,v in pairs(Content) do
					subCompile(Value.Thread,Value,Entity,Holder,Compile,i,v,(tonumber(i) and v) or nil )
				end
			end
		end
	end
	mainFunc(Value.Tab)
	--> main func

	--< cleaning
	local Clean; Clean = function()
		if Value.Thread and Clean ~= nil then
			Utility.RemoveFromThread(Value.Thread,Clean)
		end
		Value.__cleanFunction = nil;
		Utility.ClearAllConnections(ConnectionsHolder,connectionslength)
		tc(ConnectionsHolder)
		cleanHolder(Value.Thread,Holder)
		Holder = nil;
		currentnumber = nil;
		ConnectionsHolder = nil;
		connectionslength = nil;
		--print("clean ",script.Name)
	end
	--> cleaning
	Value.__cleanFunction = Clean
end