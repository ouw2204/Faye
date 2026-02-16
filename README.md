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
Faye = "mountaindouw/faye@2.2.6"
```
### Github
The [releases](https://github.com/ProphetOuw/Faye/releases) page.
## Update log
### v2.2.0
- Added Lerp system (`Thread:Lerp`) — smooth linear interpolation with exponential decay
- Lerp supports reactive Values as goals for automatic replay
- Lerp Workers — multiple instances can share a single Lerp
- Lerp `From` parameter for setting initial position
- Lerp methods: `Skip`, `Stop`, `Destroy`
- Lerp completion detection with automatic cleanup
### v2.1.8
- Fixed types
