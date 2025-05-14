---
sidebar_position: 3
---
# Utilities
A bunch of useful and essential utilities.
### 1. Value
This is the foundation of reactivity. Works like variables except components will react to it.
```lua
local Color = Thread:Value(Color3.new(1,1,1))
Thread:Create "Frame" {
    BackgroundColor3 = Color;
}
while true do
    task.wait(1)
    Color:Set(BrickColor.random().Color)
end
```
I won't go through all of its methods here, for that check its [api](../api/Value). You can set a value's value to anything. I will also use it in alot of examples, so you should learn how to use it with other utilities if you continue reading.
#### Special Metamethods
You can use += and -= instead of :Add and :Remove
### 2. Animations
Since alot of its methods are Internal, the api won't be helpful, the description here should be all you need to know.
#### Info Tables
You can create these using the threader, or u can create them directely from the Info helper module.
```lua
local Info = require(Faye.Info)
local SpringInfo = require(Faye.SpringInfo)

local AnimInfo = Info( -- or Thread:Info
    Time: number?,
    EasingStyle: Enum.EasingStyle?,
    EasingDirection: Enum.EasingDirection?,
    RepeatCount: number?,
    Reverse: boolean?,
    DelayTime: number?
)
local AnimSpringInfo = SpringInfo( -- or Thread:SpringInfo
    Time: number?,
    Frequency: number?, -- frequency
    Damping: number?, --loss of energy
    RepeatCount: number?,
    Reverse: boolean?,
    DelayTime: number?
)
```
Using SpringInfo in the Info section instead of a regular info table changes the animation into a spring. You can also set these in a value so that the info is reactive, this will allow u to use different infos for one animation, You can even switch between regular Info and Springs.
#### Creating Animations.
```lua
Thread:Create "Frame" {
    --Thread:Animate(Goal,Info)
    BackgroundColor3 = Thread:Animate(Color3.new(1,1,0),InfoTable); -- tweens smoothly to the color
}
```
You can place a value in place of the goal and everytime the value is changed, it'll set the new animation goal to that new value.
```lua
local Color = Thread:Value(Color3.new(1,1,1))
Thread:Create "Frame" {
    BackgroundColor3 = Thread:Animate(Color,InfoTable); -- tweens smoothly to the color and updates everytime the Color value is changed
}
while true do
    task.wait(1)
    Color:Set(BrickColor.random().Color)
end
```
#### From and AlwaysFrom
If you want your reactive animation to start from a designated value you can do this in two ways
##### From
This will only make it start at that value once
```lua
Thread:Create "Frame" {
    BackgroundColor3 = Thread:Animate(Color,InfoTable):From(Color3.new(1,1,1));
}
```
##### This will always make it start at that set value on each update
```lua
Thread:Create "Frame" {
    BackgroundColor3 = Thread:Animate(Color,InfoTable):AlwaysFrom(Color3.new(1,1,1));
}
```
### 3. Do
Like functions, Do code blocks can be used dynamically, only difference is they react to a value's change. So everytime a value they are listening to is changed, the do code block will run. To listen to the value we use the 'Grab' function provided.
```lua
Thread:Create "Frame" {
    BackgroundColor3 = Thread:Do(function(Grab,Thread)
        local Color = Grab(Color)
        return Color3.new(Color.R+.15,Color.G+.15,Color.B+.15)
    end);
}
```
Like functions, this can also be used to create elements(anything returned will be compiled). Do can also be used without being in the props table.
```lua
local Modified = Color3.new(1,1,1);
Thread:Do(function(Grab,Thread)
    local Color = Grab(Color)
    Modified = Color3.new(Color.R+.15,Color.G,Color.B)
end):Run()
```
### 4. State
State is a very important utility, as it allows pages. They are similar to Do's except they don't have a 'Run' method so they can only be compiled in a props table, the **big difference** is that everytime they are called they clean the previous session, this makes them ideal for creating pages.
```lua
Thread:Create "Frame" {
    Thread:State(function(Grab,InnerThread)
        local CurrentPage = Grab(Page)
        if CurrentPage == "Intro" then
            return InnerThread:Create "Frame" {} -- page 1
        else
            return InnerThread:Create "ScrollingFrame" {} -- page 2
        end
    end);
}
```
:::warning
For State and Do it is important to use the Thread parameter given instead of the one used to create the utility.
:::
### 5. Properties & Attributes
You can attach these to any instance and it will connect to the given attribute or property. This is just another form of Value so you can do everything you can do with Value with them.
```lua
local EnabledAttribute = Thread:Attribute(Workspace,"Enabled")
local SizeProperty = Thread:Property(Frame,"Size")

SizeProperty:Set(...);
SizeProperty:Get(...);
EnabledAttribute:Set(...)
EnabledAttribute += ...
```
The only notable difference is the "ReCalibrate" method which lets u re-set the Instance and/or Attribute/Property.
```lua
local SizeProperty = Thread:Property(Frame,"Size")
SizeProperty:ReCalibrate(Frame2,"Position")
--if u only wanna change the property its listening to you do:
SizeProperty:ReCalibrate(nil,"Size")
--if u wanna change the instance you do
SizeProperty:ReCalibrate(Frame5)
```
### 6. Iterate
Iterate is as a translater for tables, you pass in a table and it will go through each index and value and transform them using a function.
```lua
local table = {"Hi","How","Are","You"}
local Transformer = Thread:Iterate(table,function(Index: any,Value: any,InnerThread: Thread,Entity: Instance)
    --return index,value, this modifiers both the index and the value
    --return value, this only modifies the value and not the index
    return Index..Value
end)
local newtable = Transformer:Get() -- {"1Hi","2How","3Are","4You"}
```
#### Using iterate in a props table
This utility is very different when used inside a props table, just like State and Do, everything that's returned will be compiled, in this case it becomes important to use the InnerThread instead of the Thread used to create the Iterate utility because like state it cleans the old session. If the table passed is a Value Utility that has the Value of a table, each time you Add or Remove an item it'll only clean the last state of that item, everything that was unchanged won't be updated.
```lua
{
    Thread:Iterate(5,function(Index,Value,InnerThread)
        return InnerThread:Create "Frame" {
            Name = Value;
        }
    end)
}
```
As you can see here i inputed 5 in place of a table, when you input a number it counts from 1 to that number, this makes it so that you don't have to create tables for simple iterate procedures, This also works for Value utilities with a number as value.
#### Index and Value returning in props Iterate
Returning an index and value as seen in the none props table version won't work in the same way as the compiler uses the first returned value, to go around this you can wrap them in a table.
```lua
local PropertiesTable = {
    Size = UDim2.new(1,0,1,0);
    BackgroundColor3 = Color3.new(1,1,0)
}

Thread:Create "Frame" {
    Thread:Iterate(PropertiesTable,function(Index,Value,InnerThread)
        return {Index = Value}
    end)
}
```
### 7. Space
Spaces are another key Faye feature. It reduces the need to create connections/code for each component as it will all be handled into the space.
```lua
local Option = require(script.Option)
local Space = Thread:Space(function(Variables,Color)
    if SomeValue.Value == 1 then
        ...
    else
        ...
    end
end)
Thread:Create "Frame" {
    Thread:Iterate(5,function(Index,Value,Thread)
        return Option(Thread,Index,Value,Space)
    end)
}
```
After we create a space we can connect a signal to it(when the signal is fired it'll run all the tasks), or we can connect a signal to a specific task.
```lua
Space:Connect(SomeValue.Changed)
Space:Connect(SomeValue.Changed,"SomeId") -- connects this signal to a task with this id
```
Next ill show how to create tasks.
```lua
--In the option component
return (Index: number, Value: number,Thread: Types.Thread,Space: Types.Space)
    local Color = Thread:Value(Color3.new(1,2,3))
    local Variables = {Name = number}
    local Task = Space:Add({
        Variables,
        Color
    },Thread?) -- the Thread parameter is optional, if not passed it will assume the thread that created the Space.
end)
```
:::warning
Although the Thread parameter for a task is optional, its useful if u want the task to be deleted when the inner-thread is cleaned. If you don't pass a thread then the task will be cleaned when the Thread that created the space is cleaned.
:::
You can set a task's Id with the :SetId method.
```lua
Task:SetId("SomeId")
```
Setting this id will allow us to be able to connect a signal to it as seen above.
You can also manuelly signal the space to Call the task.
```lua
Task:Call()
```
You can connect a signal to a task using
```lua
Task:Connect(Signal)
```
:::note
Passing none reactive values or tables when creating tasks is only useful if those values are set to never change, this is because it uses table.unpack to unload those parameters so dictionaries will just be ignored.
:::
### 8. SetTo
This utility allows you to set the value of a certain Value Utility to the current GUI object being compiled.
```lua
local FrameValue = Thread:Value()
{
    Thread:Create "Frame" {
        Name = "TestFrame";
        Thread:SetTo(FrameValue)
    }
}
print(FrameValue:Get()) -- TestFrame Gui Object
```
### 9. Event
Lets you connect to multiple events at once and handle everything in one code block.
```lua
Thread:Event(Instance,{"ChildAdded","ChildRemoved"},function(Event:String, params...)
    if Event == "ChildAdded" then
        ...
    else
        ...
    end
end)
```
### 10. Inputer
Getting the UserInputService is tricky if u are using a UI library, the inputer utility allows you to quickly go around this.
#### In a viewport
```lua
local Inputer = require(Faye.Inputer)
local Input = Inputer:Get()
return function(Target)
    local MousePosition = Inputer:GetMousePosition()
end
```
This version of using inputer just gets the UserInputService, so you can place it on top of the function and it'll still work fine.
#### Inside a UI viewer window
Unlike the viewport version, you must call the GetMousePosition method in a InputBegan,Changed, or Ended code block as this uses the target to draw input.
```lua
local Inputer = require(Faye.Inputer)
return function(Target)
    local Input = Inputer:Get(Target)
    Thread:Connect(Input.InputBegan,function(InputObject)
        local MousePosition = Inputer:GetMousePosition(Input, InputObject.Position)
    end)
end
```
Its important to understand that the input connections aren't directely added to the thread so u must do it manuelly.
:::note
Recommended to use it with the UI-Hub plugin made by me as it auto switches UserInputService automatically if done in a viewport.
:::