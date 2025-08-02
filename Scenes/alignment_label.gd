extends Label



func set_alignment_label() -> void:
	var alignment = $"../..".alignment_mode_status
	var aligment_str = "None"
	if alignment == 1:
		aligment_str = 'Tangent to Velocity'
	elif alignment == 2:
		aligment_str = 'Normal to Velocity'
	elif alignment == 3:
		aligment_str = 'Anti-Normal to Velocity'
		
	self.text = "Alignment: %s" % aligment_str


func _process(delta: float) -> void:
	set_alignment_label()
