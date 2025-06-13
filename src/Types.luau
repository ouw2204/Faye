local props = require(script.Parent.Misc.PropertyTypes);

export type Value = {
    Set: (self: Value, Value: any) -> ();
    Get: (self: Value) -> ();
    Add: (self: Value, Value: any,...any) -> ();
    Remove: (self: Value,Value: any) -> ();
    Initial: any;
    Value: any;
    ReCalibrate: (self: Value, Instance: Instance?, Property: string?) -> ();
    Changed: RBXScriptSignal;
    Reset: (self: Value) -> ();
    Compare: (Value: any) -> boolean;
    Destroy: (self: Value) -> ();
    Refresh: (self: Value) -> ();
    GetItem: (self: Value,Index: any) -> any;
    ItemExists: (self: Value, Entity: any) -> ();
}
export type UserInputType = typeof(game:GetService("UserInputService"));
export type BasicThread = {Remove: (self: BasicThread, Entity: any) -> (); Add: (self: BasicThread, Entity: any) -> ()}
export type AnimationType = {
    From: (self: AnimationType, Value: any) -> AnimationType;
    AlwaysFrom: (self: AnimationType, Value: any) -> AnimationType;
    Play: (self: AnimationType,To: any) -> ();
    Skip: (self: AnimationType) -> ();
    Destroy: (self: AnimationType) -> ();
    UpdateInfo: (self: AnimationType, Info: {Time: number?,EasingStyle: Enum.EasingStyle?,EasingDirection: Enum.EasingDirection?,Reverse: boolean?,DelayTime: number?,Frequency: number?,Damping: number?,RepeatCount: number?}) -> AnimationType;
}
export type Info = {Time: number; EasingStyle: Enum.EasingStyle; EasingDirection: Enum.EasingDirection; RepeatCount: number; Reverse: boolean; DelayTime: number}
export type SpringInfo = {Time: number; Frequency: number; Damping: number; RepeatCount: number; Reverse: boolean; DelayTime: number}
--[[export type InputType = {
    Get: (self: InputType, Target: Instance?) -> UserInputType;
    Type: (self: InputType, Input: UserInputType) -> UserInputType;
    GetMousePosition: (self: InputType, Input: UserInputType,From: Vector3?) -> Vector3;
    GetMousePositionNoInsets: (self: InputType, Input: UserInputType,From: Vector3?) -> Vector3;
}]]
export type Connection = {
    Disconnect: (self: Connection) -> ();
    Destroy: (self: Connection) -> ();
}
export type Signal = {
    Fire: (self: Signal) -> (),
    Connect: (self: Signal, func: () -> ()) -> Connection,
    Once: (self: Signal, func: () -> ()) -> Connection,
    DisconnectAll: (self: Signal) -> (),
    Destroy: (self: Signal) -> ()
}
export type DelayValueType = {
    Get: (self: DelayValueType) -> ();
    Changed: RBXScriptSignal;
    SetTime: (self: DelayValueType, Time: number) -> ();
    Sensitive: (self: DelayValueType) -> DelayValueType;
    ResetTime: (self: DelayValueType) -> ();
    For: (self: DelayValueType, Value: any, Time: number?) -> DelayValueType;
    Destroy: (self: DelayValueType) -> ();
};
export type DelayType = {
    From: (self: DelayType, Props: props.Property) -> DelayType;
    Destroy: (self: DelayType) -> ();
}
type DoType = {
    Run: (self: DoType) -> DoType;
    Destroy: (self: DoType) -> ();  
};
export type SpaceTask = {
    Destroy: (self: SpaceTask) -> ();
    Call: (self: SpaceTask) -> SpaceTask;
    Variables: {any: any};
    Parameters: {[any]: any};
    SetId: (self: SpaceTask, Id: string) -> SpaceTask;
    Connect: (self: SpaceTask, Connection: RBXScriptSignal) -> RBXScriptConnection;
    AddParameter: (self: SpaceTask, Index: any,Value: any) -> ();
}
export type Space = {
    Call: (self: Space, Task: SpaceTask) -> Space;
    Add: (self: Space, Params: {[any]: any}, Thread: Thread?,IsDictionary: boolean?) -> SpaceTask;
    Remove: (self: Space, Task: SpaceTask) -> ();
    Connect: (self: Space, Connection: RBXScriptSignal,Id: string) -> RBXScriptConnection;
    Destroy: (self: Space) -> ();
}
export type Spawn = {
    Perform: (self: Spawn) -> ();
    Destroy: (self: Spawn) -> ();
}
export type Event = {
    Destroy: (self: Event) -> ();
    Call: (...any) -> Event;
    Connect: (self: Event, Connection: RBXScriptSignal) -> Event;
}
export type Thread = {
    Create: (self: Thread, ClassName: string) -> (Properties: props.Property) -> {Instance: Instance, Thread: BasicThread};
    Configure: (self: Thread, Entity: any) -> (Properties: props.Property) -> {Instance: Instance, Thread: BasicThread};
    Extend: (self: Thread) -> Thread;
    Clean: (self: Thread) -> ();
    Value: (self: Thread,Initial: any) -> Value;
    Animate: (self: Thread, Goal: any, Info: Info | SpringInfo) -> AnimationType;
    Info: (self: Thread?, Time: number?,EasingStyle: Enum.EasingStyle?,EasingDirection: Enum.EasingDirection?, RepeatCount: number?,Reverse: boolean?,DelayTime: number?) -> Info;
    SpringInfo: (self: Thread?, Time: number?,Frequency: number?,Damping: number?, RepeatCount: number?,Reverse: boolean?,DelayTime: number?) -> SpringInfo;
    Connect: (self: Thread, Connection: RBXScriptSignal, Function: (...any) -> ()) -> (),
    Do: (self: Thread, Function : (Grab: any) -> (),Entity: Instance?) -> DoType;
    State: (self: Thread, Function : (Grab: any,InnerThread: Thread,Entity: Instance?) -> ()) -> ();
    Iterate: (self: Thread, Table: any,Function: (Index: any,Value: any?,InnerThread: Thread?,Entity: Instance?) -> ()) -> ();
    Property: (self:any, Entity: any, Property: string) -> Value;
    Attribute: (self:any, Entity: any, Attribute: string) -> Value;
    DelayValue: (self: Thread, Value: Value, Time: number) -> DelayValueType;
    Delay: (self: Thread, Props: props.Property,Time: number) -> DelayType;
    SetTo: (self: Thread, Value: Value) -> {};
    Signal: (self: Thread) -> Signal;
    Listener: (self: Thread, Entity: any, Event: string & {string}, func: (string,...any) -> ()) -> {};
    Add: (self: Thread,Entity: any) -> ();
    Remove: (self: Thread,Entity: any) -> ();
    Space: (self: Thread, func: (...any) -> ()) -> Space,
    Spawn: (self: Thread,func: (...any)-> ()) -> Spawn;
    Event: (self: Thread,Connection: RBXScriptSignal & {RBXScriptSignal}, func: (...any) -> ()) -> Event;
    EventState: (self: Thread,Connection: RBXScriptSignal & {RBXScriptSignal}, func: (...any) -> ()) -> Event;
}

return nil;