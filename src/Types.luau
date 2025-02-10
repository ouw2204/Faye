local props = require(script.Parent.Misc.PropertyTypes);

export type Value = {
    Set: (self: Value, Value: any) -> ();
    Get: (self: Value) -> ();
    Add: (self: Value, Value: any) -> ();
    Remove: (self: Value,Value: any) -> ();
    Initial: any;
    Changed: RBXScriptSignal;
    Reset: (self: Value) -> ();
    Compare: (Value: any) -> boolean;
}
export type UserInputType = typeof(game:GetService("UserInputService"));
export type BasicThread = {Remove: (self: any, Entity: any) -> (); Add: (self: any, Entity: any) -> ()}
export type AnimationType = {
    From: (self: AnimationType, Value: any) -> AnimationType;
    Play: (self: AnimationType,To: any) -> ();
    Skip: (self: AnimationType) -> ();
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
    Sensitive: (self: DelayType) -> DelayType;
    ResetTime: (self: DelayType) -> ();
};
export type Thread = {
    Create: (self: any, ClassName: string) -> (Properties: props.Property) -> {Instance: Instance, Thread: BasicThread};
    Configure: (self: any, Entity: any) -> (Properties: props.Property) -> {Instance: Instance, Thread: BasicThread};
    Extend: (self: any) -> Thread;
    Clean: (self: any) -> ();
    Value: (self: any,Initial: any) -> Value;
    Animate: (self: any, Goal: any, Info: Info | SpringInfo) -> AnimationType;
    Info: (self: any, Time: number,EasingStyle: Enum.EasingStyle,EasingDirection: Enum.EasingDirection, RepeatCount: number,Reverse: boolean,DelayTime: number) -> Info;
    SpringInfo: (self: any, Time: number,Frequency: number,Damping: number, RepeatCount: number,Reverse: boolean,DelayTime: number) -> SpringInfo;
    Connect: (self: any, Connection: RBXScriptSignal,Function: () -> ()) -> ();
    Do: (self: any, Function : (Grab: any) -> (),Entity: Instance) -> ();
    State: (self: any, Function : (Grab: any,InnerThread: Thread,Entity: Instance) -> ()) -> ();
    Iterate: (self: any, Table: any,Function: (Index: any,Value: any,InnerThread: Thread,Entity: Instance) -> ()) -> ();
    Property: (self:any, Entity: any, Property: string) -> Value;
    Attribute: (self:any, Entity: any, Attribute: string) -> Value;
    Delay: (self: any, Value: Value, Time: number) -> DelayType;
    SetTo: (self: any, Value: Value) -> {};
    Event: (self: any, Entity: any, Event: any, Function: <p1,p2,p3>(Event: string,p1,p2,p3) -> ()) -> {};
    Add: (self: any,Entity: any) -> ();
    Remove: (self: any,Entity: any) -> ();
}

return {
 Thread = nil;
 DelayType = nil;
 Info = nil;
 SpringInfo = nil;
 InputType = nil;
 AnimationType = nil;
 BasicThread = nil;
 UserInputType = nil;
 Value = nil;
};