export type Value = {
    Set: (self: Value, Value: any,signalIsBasic: boolean?) -> ();
    Get: (self: Value) -> any;
    Add: (self: Value, Value: any,...any) -> ();
    Remove: (self: Value,Value: any) -> ();
    Initial: any;
    Value: any;
    ReCalibrate: (self: Value, Instance: Instance?, Property: string?) -> ();
    Changed: RBXScriptSignal;
    Reset: (self: Value) -> any;
    Compare: (Value: any) -> boolean;
    Destroy: (self: Value) -> ();
    Refresh: (self: Value) -> ();
    GetItem: (self: Value,Index: any) -> any;
    ItemExists: (self: Value, Entity: any) -> ();
}
export type FayeInstance = {
	Props: {[any]: any}?;
	Instance: Instance, Thread: Thread?, InnerThread: Thread?,
	SetAttribute: (self: FayeInstance,Name: string,Value: any) -> FayeInstance,
	GetAttribute: (self: FayeInstance,Name: string) -> any,
	GetAttributes: (self: FayeInstance) -> {any: any};
	AddTag: (self: FayeInstance,Tag: string) -> FayeInstance,
	RemoveTag: (self: FayeInstance,Tag: string) -> FayeInstance,
	HasTag: (self: FayeInstance,Tag: string) -> boolean,
	GetTags: (self: FayeInstance) -> {string};
	Clone: (self: FayeInstance) -> Instance;
	Destroy: (self: FayeInstance) -> ();
	Compile: (self: FayeInstance) -> ();
	--> new
	Remove: (self: FayeInstance, Item: any) -> ();
	Connect: (self: FayeInstance, Connection: RBXScriptSignal, Function: (...any) -> ()) -> RBXScriptConnection;
	Add: (self: FayeInstance, Item: any, IsConnection: boolean) -> any;
	ClearCache: (self: FayeInstance) -> ();
	-->
}
export type UserInputType = typeof(game:GetService("UserInputService"));

export type Animation = {
    __animId: string;
	Destroy: (self: Animation) -> ();
	Stop: (self: Animation) -> ();
	Skip: (self: Animation) -> PlayableAnimation;
}
export type Info = {Time: number; EasingStyle: Enum.EasingStyle; EasingDirection: Enum.EasingDirection; RepeatCount: number; Reverse: boolean; DelayTime: number}
export type SpringInfo = {Time: number; Frequency: number; Damping: number; RepeatCount: number; Reverse: boolean; DelayTime: number}

export type Connection = {
    Disconnect: (self: Connection) -> ();
    Destroy: (self: Connection) -> ();
}
export type AnimationModifications = {
	FirstGoal: any;
	FirstDelayTime: number?;
	FirstInfo: (Info | SpringInfo)?;
	From: any;
	AlwaysFrom: any;
}

export type DelayValue = {
    Get: (self: DelayValue) -> ();
    Changed: RBXScriptSignal;
    SetTime: (self: DelayValue, Time: number) -> ();
	Refresh: (self: DelayValue) -> ();
    Sensitive: (self: DelayValue) -> DelayValue;
    ResetTime: (self: DelayValue) -> ();
    For: (self: DelayValue, Value: any, Time: number?) -> DelayValue;
    Destroy: (self: DelayValue) -> ();
};
export type SpecialThreadParams = {
	Lifetime: number;
	YieldSafe: boolean?
}
export type Delay = {
    Destroy: (self: Delay) -> ();
}
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
    Call: (self: Space) -> Space;
    Add: (self: Space, Params: {[any]: any}, Thread: Thread?,NoUnpack: boolean?) -> SpaceTask;
    Remove: (self: Space, Task: SpaceTask) -> ();
    Connect: (self: Space, Connection: RBXScriptSignal,Id: string) -> RBXScriptConnection;
    Destroy: (self: Space) -> ();
}
export type PlayableAnimation = {
	Play: (self: PlayableAnimation) -> PlayableAnimation;
	Stop: (self: PlayableAnimation) -> ();
	Pause: (self: PlayableAnimation) -> PlayableAnimation;
	Resume: (self: PlayableAnimation) -> PlayableAnimation;
	Skip: (self: PlayableAnimation) -> PlayableAnimation;
	Destroy: (self: PlayableAnimation) -> ();
}
export type YieldSafe = {
    Destroy: (self: YieldSafe) -> ();
}
export type Signal = {
    Destroy: (self: Signal) -> ();
    Call: (...any) -> Signal;
    Connect: (self: Signal, Connection: RBXScriptSignal) -> Signal;
}
export type Thread = {
	IsActive: boolean?;
    Create: (self: Thread, ClassName: string) -> (Properties: Properties) -> FayeInstance;
    Configure: (self: Thread, Entity: any) -> (Properties: Properties) -> FayeInstance;
    Extend: (self: Thread) -> Thread;
    Destroy: (self: Thread) -> ();
    Value: (self: Thread,Initial: any) -> Value;
    Animation: (self: Thread, Goal: any, Info: (Info | SpringInfo)?,Modifications: AnimationModifications?) -> Animation;
    Info: (Time: number?,EasingStyle: Enum.EasingStyle?,EasingDirection: Enum.EasingDirection?, RepeatCount: number?,Reverse: boolean?,DelayTime: number?) -> Info;
    SpringInfo: (Time: number?,Frequency: number?,Damping: number?, RepeatCount: number?,Reverse: boolean?,DelayTime: number?) -> SpringInfo;
    Connect: (self: Thread, Cofnnection: RBXScriptSignal, func: (...any) -> ()) -> (),
    Do: (self: Thread, func : (Grab: (Value: Instance | Value) -> any,Entity: Instance?) -> ()) -> any;
    State: (self: Thread, func : (Grab: (Value: Instance | Value) -> any,Thread: Thread, Entity: Instance?) -> ()) -> any;
    Iterate: (self: Thread, Table: any,func: (Index: any,Value: any,InnerThread: Thread,Entity: Instance) -> ()) -> ();
	AdvancedIterate: (self: Thread, Table: any,func: (Index: any,Value: any,InnerThread: Thread,Entity: Instance) -> ()) -> ();
    InstancePropertySync: (self:Thread, Entity: Instance, Property: string) -> Value;
    InstanceAttributeSync: (self:Thread, Entity: Instance, Attribute: string) -> Value;
    DelayValue: (self: Thread, Value: Value?, Time: number?) -> DelayValue;
    DelayProperty: (self: Thread, Props: Properties,Time: number,From: Properties?) -> ();
    SetTo: (self: Thread, Value: Value) -> {};
    Listener: (self: Thread, Entity: any, Event: string | {string}, func: (string,...any) -> ()) -> ();
    Add: (self: Thread,Entity: any) -> ();
    Remove: (self: Thread,Entity: any) -> ();
    Space: (self: Thread, func: (...any) -> ()) -> Space,
    YieldSafe: (self: Thread,func: (...any)-> (),DelayTime: number?) -> YieldSafe;
    Schedule: (self: Thread,Time: number?,Item: any,...any) -> any;
    Signal: (self: Thread,any,func: (Thread: Thread, Entity: Instance, ...any) -> ()?) -> Signal;
    SignalState: (self: Thread,any, func: (Thread: Thread, Entity: Instance, ...any) -> ()) -> Signal;
	MethodSignaled: (self: Thread, Method: string, Index: string,RunOnInitialization: boolean?) -> ();
	Spawn: (self: Thread, func: (...any) -> (),...any) -> thread;
	Delay: (self: Thread,time: number, func: (...any) -> (),...any) -> thread;
	LoadAnimation: (self: Thread, Entity: Instance,Goal: Properties, Info: (Info | SpringInfo)?) -> PlayableAnimation;
	ModifyAnimation: (self: Thread, Animaiton: {any: any},Modifications: AnimationModifications) -> {any: any};
	CloneAnimation: (self: Thread, Animaiton: {any: any},Modifications: AnimationModifications) -> {any: any};
	Reactive: (self: Thread, func: (Grab: (Value: Instance | Value) -> any) -> ()) -> (() -> ())?;
	CloneTable: (Table: {any: any}, cloneFunction: (Index: any, Value: any) -> (any, any)?) -> {any: any};
	Debris: (self: Thread, Item: any, Lifetime: number) -> ();
	SpecialThread: (self:Thread, func: (InnerThread: Thread, Entity: Instance) -> (),Params: (SpecialThreadParams | number) ?) -> ();
}

export type Properties = {
	After: (Properties | (Entity: Instance) -> any)?;
	Before: (Properties | (Entity: Instance) -> any)?;
	GroupColor3: any, -- Color3 value that tints all descendant GuiObjects
	GroupTransparency: any, -- Number (0-1) that sets transparency for all descendants
	
	Video: any,
	ClearTextOnFocus: any,
	Rotation: any,
	Wraps: any,
	CellSize: any,
	Padding: any,
	CellPadding: any,
	ZIndex: any,
	PlaceholderText: any,
	AbsolutePosition: any,
	AbsoluteSize: any,
	AbsoluteContentSize: any,
	TextBounds: any,
	DisplayOrder: number?,
	FontFace: any,
	ScrollBarImageColor3: any,
	ScrollBarTransparency: any,
	TopImage: any,
	MidImage: any,
	BottomImage: any,
	ScrollBarThickness: any,
	TextSize: any,
	CanvasSize: any,
	CanvasPosition: any,
	HorizontalAlignment: any,
	VerticalAlignment: any,
	FillDirection: any,
	TextTransparency: any,
	TextStrokeTransparency: any,
	ClipsDescendants: any,
	SortOrder: any,
	AspectRatio: any,
	AspectType: any,
	DominantAxis: any,
	Properties: any,
	Name: any,
	Parent: any,
	Anchored: any,
	BrickColor: any,
	CanCollide: any,
	Selectable: any,
	CastShadow: any,
	Color: any,
	Material: any,
	Reflectance: number?,
	Transparency: any,
	Thickness: any,
	Shape: any, -- Specific to parts like Part, Ball, Cylinder
	RichText: any,
	-- BasePart Events
	
	--<new stroke properties
               -- UIStroke.Thickness (pixels when FixedSize)
ApplyStrokeMode: any,          -- Enum.ApplyStrokeMode
BorderStrokePosition: any,-- Enum.BorderStrokePosition (Inner/Center/Outer)
BorderOffset: any,                -- UIStroke.BorderOffset (UDim)
LineJoinMode: any,   -- Enum.LineJoinMode (Round/Bevel/Miter)
StrokeSizingMode: any, -- Enum.StrokeSizingMode (FixedSize / maybe UDim variants)
TextWrap: any,
	-- >
	

	CursorPosition: any;
	MultiLine: any;
	PlaceholderColor3: any;
	Focused: any, -- Fired when the TextBox gains focus
	FocusLost: any, -- Fired when the TextBox loses focus
	ReturnPressedFromOnScreenKeyboard: any, -- Mobile only
	Interactable: any,
	TextEditable: any,
	--< UI Flex Item
	FlexMode: any,
	GrowRatio: any,
	ShrinkRatio: any,
	ItemAlignment: any,
	-->

	--Viewport frame
	Ambient: any,
	LightColor: any,
	LightDirection: any,
	CurrentCamera: any,
	Focus: any,

	CleanDelay: any,
	CleanFunction: ((InnerThread: Thread, Entity: Instance) -> Properties?)?,
	OnClean: ((InnerThread: Thread, entity: Instance) -> Properties?)?, -- replaces clean function
	-- Generic Instance Properties
	Archivable: any,

	-- Model Properties
	PrimaryPart: any,
	WorldPivot: any,

	-- Camera Properties
	CameraType: any,
	CFrame: any,
	FieldOfView: any,
	Focus: any,
	TextWrapped: any,
	TextXAlignment: any,
	TextYAlignment: any,
	-- UI Element Properties (TextLabel, TextButton, ImageLabel, ImageButton, etc.)
	Text: any,
	TextColor3: any,
	Font: any,
	TextScaled: any,
	BackgroundColor3: any,
	BackgroundTransparency: any,
	BorderColor3: any,
	BorderSizePixel: any,
	Size: any,
	Position: any,
	AnchorPoint: any,
	Visible: any,
	Image: any, -- For ImageLabel and ImageButton
	ImageColor3: any,
	ImageTransparency: any,
	ScaleType: any,
	SliceCenter: any,
	AutoButtonColor: any, -- For TextButton and ImageButton

	-- UI Events (TextLabel, TextButton, ImageLabel, ImageButton, etc.)
	MouseEnter: (Entity: Instance, ...any) -> ()?, -- Triggered when the mouse enters the UI element
	MouseLeave: (Entity: Instance, ...any) -> ()?, -- Triggered when the mouse leaves the UI element
	MouseMoved: (Entity: Instance, ...any) -> ()?, -- Triggered when the mouse moves over the element
	MouseWheelForward: (Entity: Instance, ...any) -> ()?, -- Triggered when the mouse wheel scrolls forward
	MouseWheelBackward: (Entity: Instance, ...any) -> ()?, -- Triggered when the mouse wheel scrolls backward
	InputBegan: (Entity: Instance, ...any) -> ()?, -- Triggered when an input begins (e.g., key press)
	InputEnded: (Entity: Instance, ...any) -> ()?, -- Triggered when an input ends (e.g., key release)
	InputChanged: (Entity: Instance, ...any) -> ()?, -- Triggered when an input changes (e.g., mouse move)
	MouseButton1Click: (Entity: Instance, ...any) -> ()?, -- Triggered when the left mouse button is clicked
	MouseButton2Click: (Entity: Instance, ...any) -> ()?, -- Triggered when the right mouse button is clicked
	MouseButton1Down: (Entity: Instance, ...any) -> ()?, -- Triggered when the left mouse button is pressed down
	MouseButton1Up: (Entity: Instance, ...any) -> ()?, -- Triggered when the left mouse button is released
	MouseButton2Down: (Entity: Instance, ...any) -> ()?, -- Triggered when the right mouse button is pressed down
	MouseButton2Up: (Entity: Instance, ...any) -> ()?, -- Triggered when the right mouse button is released
	Offset: any,
	TileSize: any,
	TextStrokeColor3: any,
	-- BillboardGui Properties
	Adornee: any,
	StudsOffset: any,
	MaxDistance: any,
	ExtentsOffset: any,
	AlwaysOnTop: any,

	-- UICorner
	CornerRadius: any,

	-- BillboardGui Events
	AdorneeChanged: (Entity: Instance, ...any) -> ()?, -- Triggered when the Adornee property changes

	-- Tool Properties
	RequiresHandle: any,
	Grip: any,
	Enabled: any,

	-- Tool Events
	Activated: (Entity: Instance, ...any) -> ()?, -- Triggered when the tool is activated
	Deactivated: (Entity: Instance, ...any) -> ()?, -- Triggered when the tool is deactivated
	Equipped: (Entity: Instance, ...any) -> ()?, -- Triggered when the tool is equipped
	Unequipped: (Entity: Instance, ...any) -> ()?, -- Triggered when the tool is unequipped

	-- Sound Properties
	SoundId: any,
	Volume: any,
	PlaybackSpeed: any,
	TimePosition: any,
	Looping: any,
	Playing: any,
	RollOffMode: any,
	MinDistance: any,

	-- Sound Events
	Played: (Entity: Instance, ...any) -> ()?, -- Triggered when the sound starts playing
	Stopped: (Entity: Instance, ...any) -> ()?, -- Triggered when the sound stops
	Ended: (Entity: Instance, ...any) -> ()?, -- Triggered when the sound finishes playing
	Looped: (Entity: Instance, ...any) -> ()?, -- Triggered when the sound loops

	-- Animation Properties
	AnimationId: any,

	-- Animation Events
	KeyframeReached: (Entity: Instance, ...any) -> ()?, -- Triggered when a specific keyframe is reached
	-- part events
	TagAdded: (Entity: Instance, ...any) -> ()?,
	TagRemoved: (Entity: Instance, ...any) -> ()?
}
return nil;