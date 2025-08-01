extends Node2D

var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p1 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p1)
	p1.setup(1.0, 1.0, Vector2(400, 400), Vector2(0, 0))
	var p2 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p2)
	p2.setup(1.0, 1.0, Vector2(800, 400), Vector2(0, 0))

func _process(delta):
	pass
