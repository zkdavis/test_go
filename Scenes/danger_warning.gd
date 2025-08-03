extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.add_theme_font_size_override("font_size", 30)
	$Label.text = "Warning! Disputed Space! Turn Back Now!"
	visibility_layer = 0

func turn_on() -> void:
	visibility_layer = 10

func turn_off() -> void:
	visibility_layer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
