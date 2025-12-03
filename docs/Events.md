---
sidebar_position: 3
---
# Instance Events and Utilties
### Basics
Placing events in the props tables, will connect the listener
```lua
{
    Touched = function()

    end
}
```
The first parameter of the events is always the Instance being worked on and following is all the other parameters
```lua
{
    Touched = function(Entity, PartTouched)
    
    end
}
```
:::note
Yes i am using an event reserved for parts, you can create anything with Faye.
:::
Utilities help you implement special properties, reactivity, and animations to your Faye Instances. Utilities also work on Instances that are Configured using the Configure function.
### MethodSignaled Utility
The **MethodSignaled** utility allows you to listen to complex instance events like, GetAttributeChangedSignal, GetPropertyChangedSignal, etc...
```lua
{
    [Thread:MethodSignaled("GetPropertyChangedSignal","Size")] = function(Entity)
        local Size = Entity.AbsoluteSize
        print(Size)
    end,
}
```
Its important to remember that complex roblox instance events don't return any parameters, so the only one that will be there is the one Faye automatically adds there which is the Entity in the first parameter position.