extends Node2D




var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

func calculate_circular_orbit_location(vel: Vector2,m: float):
	return Constants.G*m/(vel.length()**2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var radius_of_sun = 2100
	var mass_sun  = 5000
	$KillDeserters.adjust_radii(radius_of_sun*10,radius_of_sun*20)
	
	
	var center = get_window().size/2
	var p1 = ob_scene.instantiate() as Orbiting_Body
	
	$Planets.add_child(p1)
	p1.setup(mass_sun, radius_of_sun, center, Vector2(0, 0))
	p1.set_yellow()
	
	
	var earth_position = center
	var earth_mass = 500.0
	var earth_velocity = Vector2(-37, 0)
	var earth_radius = 100
	var circular_sun_orbit = calculate_circular_orbit_location(earth_velocity,mass_sun)
	earth_position.y -= circular_sun_orbit
	var p2 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p2)
	p2.setup(earth_mass, earth_radius, earth_position, earth_velocity)
	p2.set_green()
	
	var player_velocity = Vector2(-55,0)
	var circular_orbit_earth = calculate_circular_orbit_location(player_velocity,earth_mass)
	var player_postion = earth_position 
	player_postion.y -= circular_orbit_earth #- 40
	
	$Ship_Scene/CharacterBody2D.position = player_postion
	$Ship_Scene/CharacterBody2D.velocity = player_velocity + earth_velocity #- Vector2(14,0)
	$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE = 1*$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE
	$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION = 1*$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION
	$Ship_Scene.thrust_scale = 0.5*$Ship_Scene.thrust_scale


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
