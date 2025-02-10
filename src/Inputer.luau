local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService");
local IsRunning = RunService:IsRunning()
local OtherType = require(script.Parent.Types)
local GuiService = game:GetService("GuiService")
local m = {}
function m:Get(Target: Instance)
    if IsRunning == false and Target == nil then
        warn("You have to provide the root/target UI element while in edit mode for Input to work. Input = Input:Get(target).")
        return
    end
    return (IsRunning == false and Target) or UserInputService :: OtherType.UserInputType
end
function m:Type(Input: OtherType.UserInputType)
    if Input == nil then return end;
    return Input :: OtherType.UserInputType
end

function m:GetMousePosition(Input: OtherType.UserInputType, From: Vector3?)
    if Input == nil then return end;
    if IsRunning == false and From == nil then
        warn("Must provide a from position while in edit mode. GetPosition(InputObject,Input.Position)")
        return
    end
    if IsRunning == false then
        return vector.create(From.X,From.Y,0)-vector.create(Input.AbsolutePosition.X,Input.AbsolutePosition.Y,0)
    else
        local Get = Input:GetMouseLocation();
        local InsetsY = GuiService:GetGuiInset().Y
        return vector.create(Get.X,Get.Y-InsetsY,0);
    end
end
return m :: OtherType.InputType;