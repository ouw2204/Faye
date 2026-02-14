local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Faye = require(ReplicatedStorage.CAM.Faye)

return function(Target: Frame)
	local Thread = Faye.new()

	-- Basic Lerp: should smoothly move and stop when converged
	local BasicLerp = Thread:Lerp(UDim2.fromScale(.8, .05), .1)
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(255, 0, 0);
		Position = BasicLerp;
	}

	-- Worker test: multiple frames sharing the same Lerp
	local WorkerLerp = Thread:Lerp(UDim2.fromScale(.8, .2), .1)
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(0, 255, 0);
		Position = WorkerLerp;
	}
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(0, 200, 0);
		Position = WorkerLerp;
	}

	-- Skip test: instantly jumps to goal after 1 second
	local SkipLerp = Thread:Lerp(UDim2.fromScale(.8, .35), .002)
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(0, 0, 255);
		Position = SkipLerp;
	}
	task.delay(1, function() 
		print("Skipping blue lerp")
		SkipLerp:Skip()
	end)

	-- Stop test: stops at current position after 1 second
	local StopLerp = Thread:Lerp(UDim2.fromScale(.8, .5), .002)
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(255, 255, 0);
		Position = StopLerp;
	}
	task.delay(1, function()
		print("Stopping yellow lerp")
		StopLerp:Stop()
	end)

	-- Value-based goal: reactive, changes goal after 3 seconds
	local GoalValue = Thread:Value(UDim2.fromScale(.8, .65))
	local ValueLerp = Thread:Lerp(GoalValue, .1)
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(255, 0, 255);
		Position = ValueLerp;
	}
	task.delay(3, function()
		print("Changing purple lerp goal")
		GoalValue:Set(UDim2.fromScale(.2, .65))
	end)

	-- Delayed Worker test: adds a worker after the lerp has already finished
	local DelayedWorkerLerp = Thread:Lerp(UDim2.fromScale(.5, .05), .3)
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(255, 128, 0);
		Position = DelayedWorkerLerp;
	}
	task.delay(5, function()
		print("Adding delayed worker (orange) after lerp finished")
		Thread:Create "Frame" {
			Parent = Target;
			Size = UDim2.fromOffset(50, 50);
			BackgroundColor3 = Color3.fromRGB(255, 160, 0);
			Position = DelayedWorkerLerp;
		}
	end)

	-- Value-based reactive Worker test: workers with a reactive goal that changes multiple times
	local ReactiveGoal = Thread:Value(UDim2.fromScale(.6, .8))
	local ReactiveWorkerLerp = Thread:Lerp(ReactiveGoal, .1)
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(0, 255, 255);
		Position = ReactiveWorkerLerp;
	}
	Thread:Create "Frame" {
		Parent = Target;
		Size = UDim2.fromOffset(50, 50);
		BackgroundColor3 = Color3.fromRGB(0, 200, 200);
		Position = ReactiveWorkerLerp;
	}
	task.delay(3, function()
		print("Changing cyan reactive goal #1")
		ReactiveGoal:Set(UDim2.fromScale(.2, .8))
	end)
	task.delay(6, function()
		print("Changing cyan reactive goal #2")
		ReactiveGoal:Set(UDim2.fromScale(.9, .9))
	end)

	return function()
		Thread:Destroy()
	end
end
