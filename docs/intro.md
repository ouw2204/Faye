---
sidebar_position: 1
---
# Introduction
:::info Disclaimer
I may not give useable code in my examples, so don't copy everything over thinking it will work.
:::
Faye can be used in any way. You can also use the utility modules individually as you please. **Most Faye Utilities have a Thread parameter you can use to insert your own Cleaner module**(if used individually without a Faye Threader). <mark>You can also use roblox Instance values like how you would use Faye Values inside of Faye.</mark>
## Object Creation and Configuration
You can create objects using the Create function
```lua
Thread:Create("Frame") {
    ...
}
```
The first element created using Thread:Create must have a Parent property inside its props table, its children will automatically have it as a parent in the roblox tree.
```lua
Thread:Create "Frame" {
    Parent = Target;
    Thread:Create "Frame" {
        ...
    }
}
```
The Configure function works on already created Faye Instances, or roblox Instances, it implements them into the Faye ecosystem letting you use Faye Utilities and other stuff on it.
```lua
Thread:Configure(PlayerGui.ScreenGui) {
    Thread:Create "Frame" {
        ...
    }
}
```
```lua
local Frame = Thread:Create("Frame") {
    ...
}
Thread:Configure(Frame) {
    Position = ...
}
```
## Project Setup
The ideal component based project setup looks like
```lua
local Faye = (...)
return function(Parent: Instance)
    local Thread = Faye.new()

    ...

    return function()
        Thread:Destroy();
    end)
end)
```
The Thread allows you to keep track of what you create and allow you to clean everthing with one function. It is not needed, you can use Faye without a Thread as seen below
```lua
local Create = require(Faye.Create)
return function(Parent: Instance)
    Create(...)
end)
```
You can reuse some some Utilities, but a minority of them can't be reused, like the *Create* function, which creates a new Faye Instance, Faye Instances are unique due to the reactivity, so they can't be cloned and this is where the component system you might be familiar with comes in.
```lua
local EmptyFrame = function()
    return Create(...)
end

local Frame = EmptyFrame()
```
:::info
If you will use Faye utilities without the Faye Thread, you can also get them with **Faye[Utility name]**, you don't have to require the individual modules
:::