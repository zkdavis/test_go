extends Label



func set_alignment_label() -> void:
	var speed = $"../../CharacterBody2D".velocity.length()
	self.text = "Speed: %s" % speed


func _process(delta: float) -> void:
	set_alignment_label()
