extends Node2D

const MIDNIGHT_BLUE = Color(0.061, 0.061, 0.168, 1.0)
const CLOSER_STAR_LAYER : int = -5
const DISTANT_STAR_LAYER : int = -6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(MIDNIGHT_BLUE)
	$DistantStars.setup("res://Assets/Sprites/stars2.png",DISTANT_STAR_LAYER, 0.01)
	$CloserStars.setup("res://Assets/Sprites/stars1.png",CLOSER_STAR_LAYER, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
