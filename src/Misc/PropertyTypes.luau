type BasicThread = { Remove: (self: any, Entity: any) -> (), Add: (self: any, Entity: any) -> () }
type AnimationType = {
	From: (self: AnimationType, Value: any) -> AnimationType,
	Play: (self: AnimationType, To: any) -> (),
	Skip: (self: AnimationType) -> (),
}
type Value = {
	Set: (self: Value, Value: any) -> (),
	Get: (self: Value) -> (),
	Add: (self: Value, Value: any) -> (),
	Remove: (self: Value, Value: any) -> (),
	Initial: any,
	Changed: RBXScriptSignal,
	Reset: (self: Value) -> (),
}
type Info = {
	Time: number,
	EasingStyle: Enum.EasingStyle,
	EasingDirection: Enum.EasingDirection,
	RepeatCount: number,
	Reverse: boolean,
	DelayTime: number,
}
type SpringInfo = {
	Time: number,
	Frequency: number,
	Damping: number,
	RepeatCount: number,
	Reverse: boolean,
	DelayTime: number,
}

type DelayType = {
	Get: (self: DelayType) -> (),
	Changed: RBXScriptSignal,
	SetTime: (self: DelayType, Time: number) -> (),
	Sensitive: (self: DelayType) -> DelayType,
	ResetTime: (self: DelayType) -> (),
}
type Thread = {
	Create: (self: any, ClassName: string) -> (Properties: Property) -> { Instance: Instance, Thread: BasicThread },
	Configure: (self: any, Entity: any) -> (Properties: Property) -> { Instance: Instance, Thread: BasicThread },
	Extend: (self: any) -> Thread,
	Clean: (self: any) -> (),
	Value: (self: any, Initial: any) -> Value,
	Animate: (self: any, Goal: any, Info: Info | SpringInfo) -> AnimationType,
	Info: (
		self: any,
		Time: number,
		EasingStyle: Enum.EasingStyle,
		EasingDirection: Enum.EasingDirection,
		RepeatCount: number,
		Reverse: boolean,
		DelayTime: number
	) -> Info,
	SpringInfo: (
		self: any,
		Time: number,
		Frequency: number,
		Damping: number,
		RepeatCount: number,
		Reverse: boolean,
		DelayTime: number
	) -> SpringInfo,
	Connect: (self: any, Connection: RBXScriptSignal, Function: () -> ()) -> (),
	Do: (self: any, Function: (Grab: any) -> (), Entity: Instance) -> (),
	State: (self: any, Function: (Grab: any, InnerThread: Thread, Entity: Instance) -> ()) -> (),
	Iterate: (
		self: any,
		Table: any,
		Function: (Index: any, Value: any, InnerThread: Thread, Entity: Instance) -> ()
	) -> (),
	Property: (self: any, Entity: any, Property: string) -> Value,
	Attribute: (self: any, Entity: any, Attribute: string) -> Value,
	Delay: (self: any, Value: Value, Time: number) -> DelayType,
	SetTo: (self: any, Value: Value) -> {},
	Event: (self: any, Entity: any, Event: any, Function: <p1, p2, p3>(Event: string, p1, p2, p3) -> ()) -> {},
	Add: (self: any, Entity: any) -> (),
	Remove: (self: any, Entity: any) -> (),
}

export type Property = {
	Video: any,
	ClearTextOnFocus: any,
	ClearTableInCompulation: any,
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
	Touched: (otherPart: BasePart?) -> ()?, -- Triggered when something touches the part
	TouchEnded: (otherPart: BasePart?) -> ()?, -- Triggered when something stops touching the part
	CleanDelay: any,
	CleanFunction: (InnerThread: Thread, Entity: Instance) -> ()?,
	OnClean: (InnerThread: Thread, entity: Instance) -> ()?, -- replaces clean function
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
	MouseEnter: (...any) -> ()?, -- Triggered when the mouse enters the UI element
	MouseLeave: (...any) -> ()?, -- Triggered when the mouse leaves the UI element
	MouseMoved: (...any) -> ()?, -- Triggered when the mouse moves over the element
	MouseWheelForward: (...any) -> ()?, -- Triggered when the mouse wheel scrolls forward
	MouseWheelBackward: (...any) -> ()?, -- Triggered when the mouse wheel scrolls backward
	InputBegan: (input: InputObject,...any) -> ()?, -- Triggered when an input begins (e.g., key press)
	InputEnded: (input: InputObject,...any) -> ()?, -- Triggered when an input ends (e.g., key release)
	InputChanged: (input: InputObject,...any) -> ()?, -- Triggered when an input changes (e.g., mouse move)
	MouseButton1Click: (...any) -> ()?, -- Triggered when the left mouse button is clicked
	MouseButton2Click: (...any) -> ()?, -- Triggered when the right mouse button is clicked
	MouseButton1Down: (...any) -> ()?, -- Triggered when the left mouse button is pressed down
	MouseButton1Up: (...any) -> ()?, -- Triggered when the left mouse button is released
	MouseButton2Down: (...any) -> ()?, -- Triggered when the right mouse button is pressed down
	MouseButton2Up: (...any) -> ()?, -- Triggered when the right mouse button is released
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
	AdorneeChanged: (adornee: Instance?) -> ()?, -- Triggered when the Adornee property changes

	-- Tool Properties
	RequiresHandle: any,
	Grip: any,
	Enabled: any,

	-- Tool Events
	Activated: () -> ()?, -- Triggered when the tool is activated
	Deactivated: () -> ()?, -- Triggered when the tool is deactivated
	Equipped: (mouse: Mouse) -> ()?, -- Triggered when the tool is equipped
	Unequipped: () -> ()?, -- Triggered when the tool is unequipped

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
	Played: (...any) -> ()?, -- Triggered when the sound starts playing
	Stopped: (...any) -> ()?, -- Triggered when the sound stops
	Ended: (...any) -> ()?, -- Triggered when the sound finishes playing
	Looped: (...any) -> ()?, -- Triggered when the sound loops

	-- Animation Properties
	AnimationId: any,

	-- Animation Events
	KeyframeReached: (keyframeName: string) -> ()?, -- Triggered when a specific keyframe is reached
}
return nil