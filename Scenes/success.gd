extends ColorRect

var is_on = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.add_theme_font_size_override("font_size", 35)
	$Label.text = "Success! Press Enter to Continue"
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
