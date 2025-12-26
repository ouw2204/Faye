# Faye
A Roblox reactive UI framework built by MountainDouw. In the docs section i only explain the basics. to view the detailed utility info, go to the [Api](/api) section.
:::info
The Thread section in Api will contain most if not all of the utilities and their functions/methods.
:::
## Installation
Remember to occasionally check for new updates as there might be bug fixes.
### Roblox
https://create.roblox.com/store/asset/74301103261718/Faye
### Wally
```
Faye = "mountaindouw/faye@2.0.7" 
```
### Github
The [releases](https://github.com/ProphetOuw/Faye/releases) page.
## Update log
### v2.0.7
- Wrapped Do and State initial run into a task.spawn so it doesn't delay
### v2.0.5
- Renamed Types to FayeTypes
- Fixed some Space types
### v2.0.4
- DelayValue changes
    - DelayValue doesn't require a Value anymore, you can set it to anything, but if its set to a value, it will react to that value's changes instead of its own.
### v2.0.2
Version at the creation of this documentation