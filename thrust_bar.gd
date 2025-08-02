extends TextureProgressBar

const MAX_THRUST = 20
const MIN_THRUST = -20
var thrust_level = 0
var active = true

@export var gradient : Gradient

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.fill_mode = 6

func refresh_state() -> void:
	set_thrust_bar()
	$TextureRect.scale.y = -float(thrust_level)/float(MAX_THRUST)
	var bar_position = float(thrust_level + MAX_THRUST)/float(2*MAX_THRUST)
	var color = gradient.sample(bar_position)
	color.a = 0.5
	$TextureRect.modulate = color

func set_thrust_bar() -> void:
	self.value = thrust_level

func set_thrust(thrust) -> void:
	if active:
		thrust_level = thrust
		refresh_state()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	refresh_state()

func deactivate() -> void:
	active = false
