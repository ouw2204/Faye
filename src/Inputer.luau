local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService");
local IsRunning = RunService:IsRunning()
local OtherType = require(script.Parent.Types)
local GuiService = game:GetService("GuiService")
local m = {}
function m:Get(Target: Instance)
    if IsRunning == false and Target == nil then
        warn("You have to provide the root/target UI element while in edit mode for Input to work. Input = Input:Get(target).")
        return
    end
    return (IsRunning == false and Target) or UserInputService :: OtherType.UserInputType
end
function m:Type(Input: OtherType.UserInputType)
    if Input == nil then return end;
    return Input :: OtherType.UserInputType
end


function m:GetMousePositionNoInsets(Input: OtherType.UserInputType, From: Vector3?)
	return m:GetMousePosition(Input,From,true)
end
function m:GetMousePosition(Input: OtherType.UserInputType, From: Vector3?,NoInsets:boolean)
	if IsRunning == false then
		if From == nil and _G.Dock ~= nil then
			if _G.viewportview == nil or _G.viewportview == false then
				From = _G.Dock:GetRelativeMousePosition()
			elseif _G.viewportview == true then
				if NoInsets then
					local Get = UserInputService:GetMouseLocation();
					return vector.create(Get.X,Get.Y,0);
				else
					local Get = UserInputService:GetMouseLocation();
					local InsetsY = GuiService:GetGuiInset().Y
					return vector.create(Get.X,Get.Y-InsetsY,0);
				end
			elseif Input ~= nil then
				From = Input:GetMouseLocation()
			end
		end
		if From == nil then
			return vector.create(0,0,0);
		end
		if Input ~= nil then
       	 	return vector.create(From.X,From.Y,0)-vector.create(Input.AbsolutePosition.X,Input.AbsolutePosition.Y,0)
		else
			return vector.create(From.X,From.Y,0)
		end
    else
		if NoInsets then
			local Get = UserInputService:GetMouseLocation();
			return vector.create(Get.X,Get.Y,0);
		else
			local Get = UserInputService:GetMouseLocation();
			local InsetsY = GuiService:GetGuiInset().Y
			return vector.create(Get.X,Get.Y-InsetsY,0);
		end
    end
end
return m :: OtherType.InputType;