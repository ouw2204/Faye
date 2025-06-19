---
sidebar_position: 4
---
# Important Tutorials
These are none utilities that are essentials.
### 1. OnClean, CleanDelay, and CleanFunction
#### OnClean
Every animation created within this function will delay the thread from being cleaned, it will resume after the animations are done. **This won't effect the deletion of other elements in the thread just the one with the OnClean function. Which this in mind you can assume that the delay time is the animation length.**
:::warning
OnClean creates an extended thread don't use this function more than once for nested components, If you have nested components that have a clean mechanic, only have this function on the parent component.
:::
```lua
Thread:Create "Frame" {
    OnClean = function(Thread,Entity)
        Thread:Configure(Entity){
            ...
        }
    end
}
```
You have to use configure to animate the clean anim.
#### CleanDelay
Rather than being forced to play an animation to delay a thread's cleanup on a component you can set a timer.
```lua
Thread:Create "Frame" {
    CleanDelay = .2;
}
```
CleanDelay can also be a function but it must return an integer in order for it to do the delay
```lua
Thread:Create "Frame" {
    CleanDelay = function(Thread: Types.Thread,Entity: Frame)
        return .2;
    end;
}
```
:::note
CleanDelay can also be a number, parameter types are not automatic, you must set them manuelly.
:::
#### CleanFunction
Unlike OnClean, this can be added however many times, so if u use CleanDelay and OnClean on a parent component, using a CleanFunction on child components will react to that signal.
```lua
Thread:Create "Frame" {
    CleanDelay = .2;
    Thread:Create "Frame" {
        CleanFunction = function(Thread,Entity)
            -- do sometihng that lasts for .2
        end
    }
}
```
This function is not limited to child components, **it is used alongside CleanDelay**.
### 2. Importance of using spaces
Spaces allow you to write organized code, if you care about memory usage please use them.
### 3. Function > Do > State Rule
Functions are less heavier than Do blocks and because states create new threads, they are heavier than Do code blocks, therefor, use functions instead of Do code blocks when u don't need to listen to a value's change, and use Do instead of state when u aren't creating new components or don't want to delete the previous sessions on updates.