---
sidebar_position: 5
---
## Lerp
Lerp is similar to [Animations](./Animations.md) but instead of tweening with easing styles, it uses linear interpolation with a constant factor each frame. This creates a smooth, exponential decay movement that naturally slows down as it approaches the goal.

### Creation
```lua
Thread:Lerp(
    To: any, -- The goal value (or a Faye Value for reactivity)
    Factor: number?, -- How fast it interpolates (0-1), default 0.15
    From: any? -- Optional starting value (one-time)
)
```

```lua
Thread:Create "Frame" {
    Position = Thread:Lerp(UDim2.fromScale(.5, .5), .1);
}
```
The frame will smoothly lerp towards the center. A higher factor means faster movement, a lower factor means slower, smoother movement.

:::note
The factor is applied every frame, so at higher framerates the lerp will be faster. A factor of `0.1` at 60fps will feel different than at 240fps.
:::

### From
The third parameter sets an initial position before the lerp starts. This is useful to avoid the object lerping from the corner.
```lua
Thread:Create "Frame" {
    Position = Thread:Lerp(UDim2.fromScale(.5, .5), .1, UDim2.fromScale(.5, 0)); -- starts from the top center
}
```

### Reactive Lerps
Just like Animations, you can pass a Faye Value as the goal. The lerp will replay every time the value changes.
```lua
local Goal = Thread:Value(UDim2.fromScale(.8, .5))
local MyLerp = Thread:Lerp(Goal, .1, UDim2.fromScale(.5, .5))

Thread:Create "Frame" {
    Parent = Target;
    Position = MyLerp;
}

-- later...
Goal:Set(UDim2.fromScale(.2, .5)) -- smoothly lerps to the new goal
```

:::note
When using a Faye Value as the goal with a `From` parameter, the property is set to `From` on initialization without playing. The lerp only starts when the value changes for the first time.
:::

### Workers
When multiple instances use the same Lerp, the first one becomes the main entity and subsequent ones become **workers**. The lerp only completes when all entities (main + workers) have converged.
```lua
local SharedLerp = Thread:Lerp(UDim2.fromScale(.5, .5), .1)

Thread:Create "Frame" {
    Parent = Target;
    Position = SharedLerp; -- main entity
}
Thread:Create "Frame" {
    Parent = Target;
    Position = SharedLerp; -- worker
}
```
Workers with a destroyed parent are automatically cleaned up.

### Methods
```lua
local MyLerp = Thread:Lerp(UDim2.fromScale(.5, .5), .1)

MyLerp:Stop()    -- Stop at current position
MyLerp:Skip()    -- Jump to goal immediately (including all workers)
MyLerp:Destroy() -- Stop and remove from thread
```

### Example: Follow the mouse
```lua
local UserInputService = game:GetService("UserInputService")

local mousePos = UserInputService:GetMouseLocation()
local absPos = Target.AbsolutePosition
local initialPos = UDim2.fromOffset(mousePos.X - absPos.X, mousePos.Y - absPos.Y)

local MousePosition = Thread:Value(initialPos)
local MouseLerp = Thread:Lerp(MousePosition, .1, initialPos)

Thread:Create "Frame" {
    Parent = Target;
    Size = UDim2.fromOffset(30, 30);
    AnchorPoint = Vector2.new(.5, .5);
    Position = MouseLerp;
}

Thread:Connect(UserInputService.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = input.Position
        local absPos = Target.AbsolutePosition
        MousePosition:Set(UDim2.fromOffset(pos.X - absPos.X, pos.Y - absPos.Y))
    end
end)
```
