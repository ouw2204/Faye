---
sidebar_position: 10
---
# Cleanup and Lifecycle
Faye provides special props to control how instances are cleaned up.

## OnClean
`OnClean` is called <mark>before the instance is destroyed</mark>. Use it for cleanup animations, final state changes, or logging.

```lua
Thread:Create "Frame" {
    Parent = parent,

    OnClean = function(InnerThread, Entity)
        print("Frame is being destroyed!")

        -- You can return props to compile (like animations)
        return {
            BackgroundTransparency = InnerThread:Animation(1, Thread.Info(0.3))
        }
    end
}
```

The callback receives:
- **InnerThread**: A dedicated thread for cleanup operations
- **Entity**: The Roblox Instance being cleaned

:::info
When you return props from `OnClean`, Faye will wait for any animations to complete before actually destroying the instance.
:::

## CleanDelay
`CleanDelay` delays the destruction of an instance by a specified time (in seconds).

```lua
Thread:Create "Frame" {
    Parent = parent,

    CleanDelay = 2 -- Wait 2 seconds before destroying
}
```

### Dynamic delay
You can also pass a function to calculate the delay:

```lua
Thread:Create "Frame" {
    Parent = parent,

    CleanDelay = function(InnerThread, Entity)
        -- Calculate delay based on some condition
        return Entity.AbsoluteSize.X > 100 and 1 or 0.5
    end
}
```

## Combining OnClean and CleanDelay
When both are used, `OnClean` runs first, then the instance waits for `CleanDelay` before being destroyed.

```lua
Thread:Create "Frame" {
    Parent = parent,

    OnClean = function(InnerThread, Entity)
        -- Fade out animation
        return {
            BackgroundTransparency = InnerThread:Animation(1, Thread.Info(0.5))
        }
    end,

    CleanDelay = 0.5 -- Match animation duration
}
```

## CleanFunction (Legacy)
`CleanFunction` is an alias for `OnClean`. They work the same way:

```lua
Thread:Create "Frame" {
    CleanFunction = function(InnerThread, Entity)
        -- Same as OnClean
    end
}
```

## InnerThread
When you use `OnClean` or `CleanDelay`, Faye automatically creates an `InnerThread` for the instance. This thread:

- Is a child of the main thread
- Gets destroyed after the instance cleanup completes
- Can be used to track cleanup-specific resources

```lua
Thread:Create "Frame" {
    Parent = parent,

    OnClean = function(InnerThread, Entity)
        -- InnerThread is automatically created
        -- Use it for cleanup animations/operations

        InnerThread:Create "Frame" {
            Parent = Entity,
            -- This child will also be cleaned properly
        }
    end
}
```

## Animation Cleanup
Faye tracks active animations and won't destroy a thread until animations complete (if `CleanWhenDone` is set):

```lua
Thread:Create "Frame" {
    Size = Thread:Animation(UDim2.fromOffset(200, 200), Thread.Info(2)),

    OnClean = function(InnerThread, Entity)
        -- Faye waits for any InnerThread animations to finish
        return {
            Size = InnerThread:Animation(UDim2.fromOffset(0, 0), Thread.Info(0.5))
        }
    end
}
```

## Cleanup Order
When a thread is destroyed:

1. **Priority items** are cleaned first (connections added with `Thread:Add(item, true)`)
2. **Regular items** are cleaned in reverse order (last added = first cleaned)
3. **Child threads** are recursively cleaned
4. **Instance cleanup** runs (`OnClean` callback if present)
5. **CleanDelay** is waited (if present)
6. **Instance destroyed**

## Best Practices

### Do use OnClean for:
- Fade out animations
- Logging/analytics
- Notifying other systems
- Cleaning external resources

### Don't use OnClean for:
- Long-running operations (blocks cleanup)
- Creating new permanent UI (it will be destroyed)
- Heavy computations

### Example: Notification with auto-dismiss
```lua
local function Notification(message, duration)
    local Thread = Faye.new()

    Thread:Create "Frame" {
        Parent = notificationContainer,

        Thread:Create "TextLabel" {
            Text = message
        },

        OnClean = function(InnerThread, Entity)
            return {
                Position = InnerThread:Animation(
                    UDim2.new(1, 0, 0, 0),
                    Thread.Info(0.3)
                )
            }
        end,

        CleanDelay = 0.3
    }

    -- Auto-destroy after duration
    Thread:Delay(duration, function()
        Thread:Destroy()
    end)

    return Thread
end
```
