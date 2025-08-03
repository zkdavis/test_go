extends Node2D


var success = false

var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

func calculate_circular_orbit_location(vel: Vector2,m: float):
	return Constants.G*m/(vel.length()**2)


func next_scene():
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")

func prev_scene():
	get_tree().change_scene_to_file("res://Scenes/orbit_level.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var radius_of_sun = 2100
	var mass_sun  = 5000
	$KillDeserters.adjust_radii(radius_of_sun*10,radius_of_sun*20)
	
	$AudioStreamPlayer.play()
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
	$Ship_Scene.rescale_ship(0.5)
	$Ship_Scene.get_node("CharacterBody2D/Camera2D").zoom=Vector2(0.6,0.6)
	$Ship_Scene.dt_int=0.008
	$Ship_Scene.total_path_time=4
	$linepath.width=3
	
	var instr = $Ship_Scene/CanvasLayer/instructutions
	instr.get_node("Label").add_theme_font_size_override("font_size", 15)
	instr.get_node("Label").text = "Earth communication satellites suck. Remove them by either leaving the solar system or crashing into the sun. \n \n PRESS ENTER TO START"
	if !instr.get_is_on():
		instr.turn_on()

func calculate_gravitational_force(target : Orbiting_Body, source : Orbiting_Body) -> Vector2:
	var direction = target.get_pos() - source.get_pos()
	var distance = direction.length()
	if distance == 0:
		return Vector2.ZERO ## Safeguard
	var force_magnitude = Constants.G * target.get_mass() * source.get_mass() / (distance*distance)
	return -direction.normalized() * force_magnitude
	
func calculate_gravitational_potential(pos,mass, source : Orbiting_Body):
	var direction = pos - source.get_pos()
	var distance = direction.length()
	if distance == 0:
		return Vector2.ZERO ## Safeguard
	var force_magnitude = Constants.G * mass * source.get_mass() / (distance)
	return force_magnitude
	
func check_for_succes():
	var sun_body = $Planets.get_children()[0]
	var earth_body = $Planets.get_children()[1]
	var sun_potential = calculate_gravitational_potential($Ship_Scene.position,$Ship_Scene.mass,sun_body)
	sun_potential += calculate_gravitational_potential($Ship_Scene.position,$Ship_Scene.mass,earth_body)
	var direction = $Ship_Scene.position - sun_body.get_pos()
	var tang_direct = Vector2(direction.y,direction.x).normalized()
	var ship_vel = $Ship_Scene/CharacterBody2D.velocity
	var ship_tan_vel =ship_vel.dot(tang_direct)
	var ship_kin_energy = 0.5*$Ship_Scene.mass * (ship_vel.length()**2)
	if(ship_kin_energy>2*sun_potential):
		print("success")
		success=true
	
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
	
	var cont = Input.is_action_just_pressed("continue")
	check_for_succes()
	if success:
		var suc_label = $Ship_Scene/CanvasLayer/Success
		
		if !suc_label.get_is_on():
			suc_label.turn_on()
			
		if cont:
			get_tree().change_scene_to_file("res://Scenes/level_3.tscn")
	else:
		var instr = $Ship_Scene/CanvasLayer/instructutions
		if instr.get_is_on():
			if cont:
				instr.turn_off()
