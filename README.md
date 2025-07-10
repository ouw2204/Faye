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
v1.4.16
- Renamde 'Attribute' and 'Property' to 'InstanceAttribute' and 'InstanceProperty'
- Added a 'MethodSignal' class that lets you listen to signals like 'GetAttributeChangedSignal', 'InstanceAddedSignal', 'GetPropertyChangedSignal',etc...
- Added 'AddTag', 'RemoveTag', and 'GetTags' functions to Faye Instances.
- Changed Thread:Clean to Thread:Destroy()
- Removed Threader, you can now just require the Faye path