# Faye
A Roblox reactive UI framework built by ProphetOuw. In the docs section i only explain the basics. to view the detailed utility info, go to the [Api](/api) section.
## Installation
Remember to occasionally check for new updates as there might be bug fixes.
### Roblox
https://create.roblox.com/store/asset/74301103261718/Faye
### Wally
```
Faye = "prophetouw/faye@1.4.16" 
```
### Github
The [releases](https://github.com/ProphetOuw/Faye/releases) page.
## Update log
v1.5.0
- Thread:Animate -> Thread:Animation
- You can now use the Animation module without a thread
- New Method: Thread.PlayAnimation, you can also require this module and use it without a threader, it works similar tweenservice, it does not need compilation to work
- if a instances in which a ancestor already runs 'OnClean' or has the 'CleanDelay' property has a 'OnClean' property it gets transformed into 'CleanFunction' internally. CleanDelay gets ignored too if an ancestor already has the property.
- All animations now use simple tables making them even more light weight
- You can now use 1 animation on multiple Instances.
- You can now use 1 Iterate object on multiple Instances.
- You can now use 1 Do and State Object on multiple Instances.
- Since animations are now simple objects, to modify them u must pass a third parameter which is a table
```lua
Thread:Animation(Goal: any,Info: Types.Info,Modifications: Types.AnimationModifications?)

--in types module
AnimationModifications = {
	FirstGoal: any?;
	FirstInfo: (Info| SpringInfo)?;
	From: any?;
	AlwaysFrom: any?;
}
```
You can also require the modifier module indepedently and use it without the Thread.
```lua
local ModifyAnimation = require(path)
ModifyAnimation(Animation: {any: any}, Modifications: AnimationModifications)
```
- Changed Thread:Info and Thread:SpringInfo to be functions rather than methods.
```lua
--Old:
--Thread:Info(...)
--Thread:SpringInfo(...)

--New:
Thread.Info(...)
Thread.SpringInfo(...)
```
- If you want to clone then modify an animation you do
```lua
Thread:CloneAnimation(Animation: {any: any},Modification: AnimationModifications)
```
Its important to note that this creates a brand new animation object, with everything the original one had except for the Thread and Animation Modifications, those are relative.
v1.4.16
- Renamde 'Attribute' and 'Property' to 'InstanceAttribute' and 'InstanceProperty'
- Added a 'MethodSignal' class that lets you listen to signals like 'GetAttributeChangedSignal', 'InstanceAddedSignal', 'GetPropertyChangedSignal',etc...
- Added 'AddTag', 'RemoveTag', and 'GetTags' functions to Faye Instances.
- Changed Thread:Clean to Thread:Destroy()
- Removed Threader, you can now just require the Faye path