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

export type DelayType = {
    Get: (self: DelayType) -> ();
    Changed: RBXScriptSignal;
    SetTime: (self: DelayType, Time: number) -> ();
};
export type ThreaderType = {
    Create: (self: any, ClassName: string) -> (Properties: props.Property) -> {Instance: Instance, Thread: ThreadType};
    Configure: (self: any, Entity: any) -> (Properties: props.Property) -> {Instance: Instance, Thread: ThreadType};
    Extend: (self: any) -> ThreaderType;
    Clean: (self: any) -> ();
    Value: (self: any,Initial: any) -> Value;
    Animate: (self: any, Goal: any, Info: Info | SpringInfo) -> AnimationType;
    Info: (self: any, Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number) -> Info;
    SpringInfo: (self: any, Time: number,Frequency: number,Damping: number, RepeatCount: number,Reverse: boolean,DelayTime: number) -> SpringInfo;
    Connect: (self: any, Connection: RBXScriptSignal,Function: () -> ()) -> ();
    Do: (self: any, Function : (Grab: any) -> ()) -> ();
    Iterate: (self: any, Table: any,Function: (Index: any,Value: any,InnerThread: ThreaderType,Entity: Instance) -> ()) -> ();
    Property: (self:any, Entity: any, Property: string) -> Value;
    Attribute: (self:any, Entity: any, Attribute: string) -> Value;
    Delay: (self: any, Value: Value, Time: number) -> DelayType;
    SetTo: (self: any, Value: Value) -> {};
    Event: (self: any, Entity: any, Event: any, Function: <p1,p2,p3>(Event: string,p1,p2,p3) -> ()) -> {};
    Add: (self: any,Entity: any) -> ();
    Remove: (self: any,Entity: any) -> ();
}

return nil;