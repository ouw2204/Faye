local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Faye = require(ReplicatedStorage.CAM.Faye)

return function(Target: Frame)
	local Thread = Faye.new()

	local mousePos = UserInputService:GetMouseLocation()
	local absPos = Target.AbsolutePosition
	local initialPos = UDim2.fromOffset(mousePos.X - absPos.X, mousePos.Y - absPos.Y)

	local MousePosition = Thread:Value(initialPos)
	local MouseLerp = Thread:Lerp(MousePosition, .1, initialPos)

	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(30, 30);
		AnchorPoint = Vector2.new(.5, .5);
		BackgroundColor3 = Color3.fromRGB(255, 100, 100);
		Position = MouseLerp;
	}

	Thread:Connect(UserInputService.InputChanged, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = input.Position
			local absPos = Target.AbsolutePosition
			local absSize = Target.AbsoluteSize
			MousePosition:Set(UDim2.fromOffset(pos.X - absPos.X, pos.Y - absPos.Y))
		end
	end)

	return function()
		Thread:Destroy()
	end
end
