extends Node2D

var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p1 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p1)
	p1.setup(1.0, 0.5, Vector2(400, 400), Vector2(0, 0.5))
	var p2 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p2)
	p2.setup(1.0, 0.5, Vector2(800, 400), Vector2(0, -0.5))	

func calculate_gravitational_force(target : Orbiting_Body, source : Orbiting_Body) -> Vector2:
	var G = 10000 ## GConstant
	var direction = target.get_pos() - source.get_pos()
	var distance = direction.length()
	if distance == 0:
		return Vector2.ZERO ## Safeguard
	var force_magnitude = G * target.get_mass() * source.get_mass() / (distance*distance)
	return -direction.normalized() * force_magnitude

func _physics_process(delta: float) -> void:
	var parent_node = get_node("Planets")
	var p0 = parent_node.get_child(0) as Orbiting_Body
	var p1 = parent_node.get_child(1) as Orbiting_Body
	var f01 = calculate_gravitational_force(p0, p1)
	p0.apply_force(f01)
	p1.apply_force(-f01)
