---
sidebar_position: 1
---
# Project Setup
Faye can be initiated in any manner.
```lua
local Faye = path
local Threader = require(Faye.Threader)

return function()
    local Thread = Threader()
    ...
    return function()
        Thread:Clean()
    end
end)
```
Faye also supports custom clean handlers, and the use of none(NOT RECOMMENDED).
```lua
local Create = require(Faye.create)

local object = Create ("Frame",Cleaner?) {
    ...
}
task.wait(5)
object:Destroy()
```
:::warning
Make sure to always call `Destroy()` on stuff you create without a cleaner.
:::
:::info
Please keep in mind that animations that don't have a value as goal destroy themselves automatically after the animation is done. Info, and SpringInfo do not have a destroy function, they are just simple tables, to clean them you'd use table functions which is not necessary as it should already be easy for the garbage collector.
:::
**The info and warning above only apply to people who aren't using the built in Thread handler.**