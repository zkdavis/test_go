extends Node2D

var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")
var bodies = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p1 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p1)
	p1.setup(100.0, 0.5, Vector2(400, 400), Vector2(0, 0))
	var p2 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p2)
	p2.setup(100.0, 0.5, Vector2(800, 400), Vector2(0, 0))
	for planet in $Planets.get_children():
		bodies.append(planet)


func calculate_gravitational_force(target : Orbiting_Body, source : Orbiting_Body) -> Vector2:
	var direction = target.get_pos() - source.get_pos()
	var distance = direction.length()
	if distance == 0:
		return Vector2.ZERO ## Safeguard
	var force_magnitude = Constants.G * target.get_mass() * source.get_mass() / (distance*distance)
	return -direction.normalized() * force_magnitude

func _physics_process(_delta: float) -> void:
	var parent_node = get_node("Planets")
	var num_children = parent_node.get_child_count()
	# Clear the forces
	for child in parent_node.get_children():
		child.clear_force()
	# Apply forces
	for i in range(num_children):
		for j in range(i):
			var target = parent_node.get_child(i) as Orbiting_Body
			var source = parent_node.get_child(j) as Orbiting_Body
			var force = calculate_gravitational_force(target, source)
			target.apply_force(force)
			source.apply_force(-force)
