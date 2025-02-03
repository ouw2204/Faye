local props = require(script.Parent.PropertyTypes);

export type Value = {
    Set: (self: Value, Value: any) -> ();
    Get: (self: Value) -> ();
    Add: (self: Value, Value: any) -> ();
    Remove: (self: Value,Value: any) -> ();
    Initial: any;
    Changed: RBXScriptSignal;
}
export type UserInputType = typeof(game:GetService("UserInputService"));
export type ThreadType = {Remove: (self: any, Entity: any) -> (); Add: (self: any, Entity: any) -> ()}
export type AnimationType = {
    From: (self: AnimationType, Value: any) -> AnimationType;
    Play: (self: AnimationType,To: any) -> ();
}
export type Info = {Time: number; EasingStyle: Enum.EasingStyle; EasingDirection: Enum.EasingDirection; RepeatCount: number; Reverse: boolean; DelayTime: number}
export type SpringInfo = {Time: number; Frequency: number; Damping: number; RepeatCount: number; Reverse: boolean; DelayTime: number}
export type InputType = {
    Get: (self: InputType, Target: Instance?) -> UserInputType;
    Type: (self: InputType, Input: UserInputType) -> UserInputType;
    GetMousePosition: (self: InputType, Input: UserInputType,From: Vector3?) -> Vector3;
}


export type ThreaderType = {
    Create: (self: ThreaderType, ClassName: string) -> (Properties: props.Property) -> {Instance: Instance, Thread: ThreadType};
    Extend: (self: ThreaderType) -> ThreaderType;
    Clean: (self: ThreaderType) -> ();
    Value: (self: ThreaderType,Initial: any) -> Value;
    Animate: (self: ThreaderType, Goal: any, Info: Info | SpringInfo) -> AnimationType;
    Info: (self: ThreaderType, Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number) -> Info;
    SpringInfo: (self: ThreaderType, Time: number,Frequency: number,Damping: number, RepeatCount: number,Reverse: boolean,DelayTime: number) -> SpringInfo;
    Connect: (self: ThreaderType, Connection: RBXScriptSignal,Function: () -> ()) -> ();
    Do: (self: any, Function : (Grab: any) -> ()) -> ();
    Iterate: (self: any, Table: any,Function: (Index: any,Value: any,InnerThread: ThreaderType,Entity: Instance) -> ()) -> ();
}

return nil;