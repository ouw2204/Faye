---
sidebar_position: 4
---
Values are the most important part of Faye and its reactive features.
:::note
You can use faye utilities with a Thread or you can require the utilities individually and use them, moving on i will be using the Thread for the utilities.
:::
```lua
local Size = Thread:Value(UDim2.fromOffset(100,100))
```
You can set a Value to anything, its like a roblox variable. You can also use regular roblox variables in places where you can use values, only issue is that they won't be reactive. Here are some basic value functions
```lua
Size:Set(UDim2.fromOffset(200,200)) -- set the value
print(Size:Get()) -- get the value


if Size:Compare(UDIm2.fromOffset(200,200)) then --compare the Value
    print("Success")
end

Size:Reset() -- reset the value to its initial value
Size.Initial -- the Initial value of the Value
```
The **Value:Get** function has a recursive property where if the value is a Faye Instance it will return the roblox instance inside that faye instance, and if the value is another value it will call :Get on that the nested value. There is a way to get the Value of a Faye Value without the recursiveness
```lua
print(Size.Value) -- the none recursive value
```
### Special Faye Values
Faye also offers some utilities that let you sync Values to properties and Attributes
```lua
local Value = Thread:InstanceAttributeSync(Instance,"SomeAttribute") -- Attribute sync
local Value = Thread:InstancePropertySync(Instance,"Size") -- Property sync
```
You can use these special values like you would regular values, it has support for almost all functions if not all.