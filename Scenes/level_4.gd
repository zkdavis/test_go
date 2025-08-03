extends Node2D


var success = false

var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

func calculate_circular_orbit_location(vel: Vector2,m: float):
	return Constants.G*m/(vel.length()**2)


func next_scene():
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")

func prev_scene():
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var radius_of_sun = 2100
	var mass_sun  = 5000
	$KillDeserters.adjust_radii(radius_of_sun*10,radius_of_sun*20)
	
	$AudioStreamPlayer.play()
	
	
	var center = get_window().size/2
	var center_float = Vector2(center.x,center.y)
	var p1 = ob_scene.instantiate() as Orbiting_Body
	
	$Planets.add_child(p1)
	p1.setup(mass_sun, radius_of_sun, center_float, Vector2(0, 0))
	p1.set_yellow()
	
	
	var earth_position = center_float
	var earth_mass = 500.0
	var earth_velocity = Vector2(-37, 0)
	var earth_radius = 100
	var circular_sun_orbit = calculate_circular_orbit_location(earth_velocity,mass_sun)
	earth_position.y -= circular_sun_orbit
	var p2 = ob_scene.instantiate() as Orbiting_Body
	$Planets.add_child(p2)
	p2.setup(earth_mass, earth_radius, earth_position, earth_velocity)
	p2.set_green()
	
	var mars_position = center_float
	var mars_mass = earth_mass*0.6
	var mars_radius = earth_radius*0.9
	var mars_velocity = Vector2(-32,0)
	var circular_sun_mars_orbit = calculate_circular_orbit_location(mars_velocity,mass_sun)
	mars_position += Vector2(-1,-1).normalized()*circular_sun_mars_orbit
	var p3 = ob_scene.instantiate() as Orbiting_Body
	p3.name='mars'
	$Planets.add_child(p3)
	p3.setup(mars_mass, mars_radius, mars_position, mars_velocity)
	p3.set_red()
	
	var player_velocity = Vector2(-55,0)
	var circular_orbit_earth = calculate_circular_orbit_location(player_velocity,earth_mass)
	var player_postion = earth_position 
	player_postion.y -= circular_orbit_earth #- 40
	
	$Ship_Scene/CharacterBody2D.position = player_postion
	$Ship_Scene/CharacterBody2D.velocity = player_velocity + earth_velocity #- Vector2(14,0)
	$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE = 0.5*$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE
	$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION = 0.2*$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION
	$Ship_Scene.thrust_scale = 1*$Ship_Scene.thrust_scale
	$Ship_Scene.rescale_ship(0.5)
	$Ship_Scene.get_node("CharacterBody2D/Camera2D").zoom=Vector2(0.5,0.5)
	$Ship_Scene.dt_int=0.008
	$Ship_Scene.total_path_time=4
	$linepath.width=3
	
	var instr = $Ship_Scene/CanvasLayer/instructutions
	instr.get_node("Label").add_theme_font_size_override("font_size", 15)
	instr.get_node("Label").text = "It is finally time. Leave your lush home planet for the inhospitable red desert planet. For some reason... You will have to land on the surface. \n \n PRESS ENTER TO START \n Hint: Keep your speed below 150 when landing." 
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
	var mars_body = $Planets.get_children()[2]
	
	
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
			get_tree().change_scene_to_file("res://Scenes/credits.tscn")
	else:
		var instr = $Ship_Scene/CanvasLayer/instructutions
		if instr.get_is_on():
			if cont:
				instr.turn_off()
