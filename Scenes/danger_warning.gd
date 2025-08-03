extends ColorRect

var is_on = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.add_theme_font_size_override("font_size", 15)
	$Label.text = "Low orbit satellites are needed for communication with Earth. Be sure to say with in the marked region for 20 seconds to deploy them. Press Enter to start. \n \n PRESS ENTER TO START \n \n  Hint: start by getting the peak of you arc into the region and then circulizing your orbit from the peak."
	visibility_layer = 0

func turn_on() -> void:
	is_on = true
	visibility_layer = 10

func turn_off() -> void:
	is_on = false
	visibility_layer = 0

func get_is_on():
	return is_on

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_text(txt):
	$Label.text = txt
