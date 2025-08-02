extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_fuel_label() -> void:
	self.text = "Speed: %s" % $"../../CharacterBody2D".velocity.length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_fuel_label()
