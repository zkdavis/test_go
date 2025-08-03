extends Parallax2D

var box = Vector2(1280, 720)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(file, layer: int, speed: float) -> void:
	var pic = Image.load_from_file(file)
	pic.resize(box.x,box.y)
	var pictex = ImageTexture.create_from_image(pic)
	var rect = TextureRect.new()
	self.add_child(rect)
	rect.set_size(box)
	rect.set_texture(pictex)
	self.visibility_layer = layer
	#set_ignore_camera_scroll(true)
	set_ignore_camera_scroll(false)
	set_repeat_size(box)
	set_scroll_scale(Vector2.ONE*speed)
	set_repeat_times(Constants.background_repeat)

func _process(delta: float) -> void:
	pass
