local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService");
local IsRunning = RunService:IsRunning()
local OtherType = require(script.Parent.Types)
local GuiService = game:GetService("GuiService")
local m = {}
--[=[
	@class Inputer
	```lua
	local Inputer = require(Faye.Inputer)
	```
	Inputer is not attached to any cleaning handler.
]=]

--[=[
	@method Get
	@within Inputer
	@param Target Instance?
	@return UserInputService
	This method gets the input handler, pass a target if you are doing it in a UI viewing window and not viewport.
]=]
function m:Get(Target: Instance?)
	if not (_G.Dock ~= nil and _G.viewportview) and IsRunning == false then
		return Target or UserInputService :: OtherType.UserInputType
	else
		return UserInputService :: OtherType.UserInputType
	end
end

function m:GetMousePositionNoInsets(Input: OtherType.UserInputType?, From: Vector3?)
	return m:GetMousePosition(Input,From,true)
end
--[=[
	@method GetMousePosition
	@within Inputer
	@param Input Instance?
	@param From vector3?
	@return mouse pos
	Gets the mouse position, no param needed if used in the viewport, otherwise, you must pass the Input object that you got with the :Get() function. From is used if you want to get the relative position, pass an absolute position of some ui.
]=]
function m:GetMousePosition(Input: OtherType.UserInputType?, From: Vector3?,NoInsets:boolean)
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
		if Input ~= nil and Input:IsA("GuiBase") then
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