extends Node2D




var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

func calculate_circular_orbit_location(vel: Vector2,m: float):
	return Constants.G*m/(vel.length()**2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ship_Scene.rescale_ship(1)
	$Ship_Scene.change_thrust_scale(2)
	var radius_of_moon = 100
	var mass_moon  = 50
	$KillDeserters.adjust_radii(radius_of_moon*50,radius_of_moon*75)
	
	var center = get_window().size/2
	var p1 = ob_scene.instantiate() as Orbiting_Body
	
	$Planets.add_child(p1)
	p1.setup(mass_moon, radius_of_moon, center, Vector2(0, 0))
	p1.set_grey()
	
	var player_velocity = Vector2.ZERO
	var player_postion = Vector2(0,2*radius_of_moon) 
	
	$Ship_Scene/CharacterBody2D.position = player_postion
	$Ship_Scene/CharacterBody2D.velocity = player_velocity
	$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE = 0.1*$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE
	$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION = 1*$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION
	$Ship_Scene.thrust_scale = 0.1*$Ship_Scene.thrust_scale


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
	$KillDeserters.store_ship_position_and_process($Ship_Scene/CharacterBody2D.global_position)
