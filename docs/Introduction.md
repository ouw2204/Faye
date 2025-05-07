---
sidebar_position: 2
---
# Introduction

### 1. Threads

If you are using the wally version of faye, the module itself will return the threader.
```lua
local Threader = require(Packages.Faye)
```
Faye can be used with or without a thread(scope).
#### Without:
```lua
local Create = require(path)
local Frame = Create "Frame" {
    ...
}
task.wait(2)
Frame:Destroy()
```
#### With(Recommended):
To create scopes you must require the Threader.
```lua
local Thread = require(Faye.Threader)
Thread:Create "Frame" {
    ...
}
task.wait(2)
Thread:Clean()
```
#### Difference?
Everything created using a Thread can be cleaned at once once the **Clean** function is called, this function cleans the contents, and the thread itself, hence the Thread isn't usable after its called. if you're not using any thread you must clean everything manuelly or assign a custom cleaning module(any cleaner that has an "Add" and/or "Remove" method):
```lua
local Create = require(path)
local Trove = Trove.new()
Create("Frame",Trove) {
    ...
}
task.wait(2)
Trove:Destroy()
```
### 2. Inner-Threads
Inner-Threads are extended threads, this means that they are child threads of whatever thread they are extended from.
```lua
local Thread = Threader()
local Extended = Thread:Extend()
```
When Thread is deleted, Extended is also deleted, but when Extended is deleted, Thread is uneffected.
#### Some useful thread methods
```lua
Thread:Add(any) -- add something to be cleaned on clean
Thread:Remove(any) -- remove something from being cleaned
Thread:Connect(rbxlScriptSignal,function) -- connection a signal to a function
```
### 3. Configure And Create
#### Create
Used to create a new element
```lua
Thread:Create "Frame" {
    ...
}
```
#### Configure
Used to configure an already existing component/GUI
```lua
Thread:Configure (script.Storage.Frame1) {
    ...
}
```
Or
```lua
local Frame = Thread:Create "Frame" {}
Thread:Configure (Frame) {
    ...
}
```
### 4. Nested Props
You can nest props, but the first table is special in the way that it will auto scan for properties first. If you wish to peserve priority of properties in a nested prop table, you must set it to a key named with the name 'Properties'
```lua
Thread:Create "Frame" {
    {
        {
            Properties = {
                Size = UDim2.fromOffset();
            }
        }
    }
}
```
Obviously using the 'Properties' key is optional, it'll compile eitherway but it just perserves priority(compiles the priorities first), if you aren't nesting props tables you don't need to worry about this.
### 5. Functions
Functions in Faye are useful due to how dynamic they are.
```lua
Thread:Create "Frame" {
    function()
        -- runs on compilation
    end)
}
```
Anything you return in the function will be compiled.
```lua
Thread:Create "Frame" {
    function()
        return Thread:Create "Frame" {
            Name = "Frame2";
        }
    end);
    BackgroundColor3 = function()
        if true then
            return Color3.new()
        else
            return Color3.new(1,1,1)
        end
    end)
}
```
:::note
There is a module named "Type" in the Faye folder that contains a bunch of types you can use for your parameters.
:::
### 6. Signals
```lua
{
    MouseButton1Down = function(Entity,...) -- Event = function

    end);
    SizeChanged = function(Entity,NewValue) -- [Property]Changed = function(Entity,new value)

    end);
    SizeChangedInit = function(Entity,NewValue) -- [Property]ChangedInit = function(Entity,new value)

    end)
}
```
[Property]ChangedInit fires the function initially and when it is changed, its like the regular [Property]Changed except it fires the function on initialization.