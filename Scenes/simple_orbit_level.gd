extends Node2D


var radius_of_moon = 800
var outer_radius = 1.5*radius_of_moon
var inner_radius = 1.3*radius_of_moon
var success_timer = 0
var success:bool = false

var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

func calculate_circular_orbit_location(vel: Vector2,m: float):
	return Constants.G*m/(vel.length()**2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ship_Scene.rescale_ship(1)
	$Ship_Scene.change_thrust_scale(2)
	
	$inner_radius.set_default_color(Color.RED)
	$outer_radius.set_default_color(Color.RED)
	
	var mass_moon  = 10000
	$KillDeserters.adjust_radii(radius_of_moon*50,radius_of_moon*75)
	
	var center = Vector2(get_window().size.x,get_window().size.y)/2
	var p1 = ob_scene.instantiate() as Orbiting_Body
	
	$Planets.add_child(p1)
	p1.setup(mass_moon, radius_of_moon, center, Vector2(0, 0))
	p1.set_grey()
	
	var player_velocity = Vector2.ZERO
	var player_postion =Vector2(center.x,center.y) - Vector2(0,1*radius_of_moon) 
	
	$Ship_Scene/CharacterBody2D.position = player_postion
	$Ship_Scene/CharacterBody2D.velocity = player_velocity
	$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE = 1*$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE
	$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION = 1*$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION
	
	
	var circle_points = []
	var circle_points_outer = []

	var n_points = 60
	var d_theta = 2*PI/n_points
	for i in range(1,n_points+1):
		var p = Vector2(cos(d_theta*i),sin(d_theta*i))
		circle_points.append(p*inner_radius + center)
		circle_points_outer.append(p*outer_radius + center)
	
	$inner_radius.points = circle_points
	$outer_radius.points = circle_points_outer
	$Ship_Scene.get_node("CharacterBody2D/Camera2D").zoom=Vector2(0.8,0.8)
	$linepath.width = 10
	
	$AudioStreamPlayer.play()
	
	var instr = $Ship_Scene/CanvasLayer/instructutions
	instr.get_node("Label").add_theme_font_size_override("font_size", 15)
	instr.get_node("Label").text = "Low orbit satellites are needed for communication with Earth. Be sure to say with in the marked region for 20 seconds to deploy them. Press Enter to start. \n \n PRESS ENTER TO START \n \n  Hint: start by getting the peak of you arc into the region and then circulizing your orbit from the peak."
	if !instr.get_is_on():
		instr.turn_on()
		

	

func calculate_gravitational_force(target : Orbiting_Body, source : Orbiting_Body) -> Vector2:
	var direction = target.get_pos() - source.get_pos()
	var distance = direction.length()
	if distance == 0:
		return Vector2.ZERO ## Safeguard
	var force_magnitude = Constants.G * target.get_mass() * source.get_mass() / (distance*distance)
	return -direction.normalized() * force_magnitude
	
func check_linepath(delta):
	
	var b: Orbiting_Body = $Planets.get_children()[0]
	var b_pos =  b.get_pos()
	

	var player_pos = $Ship_Scene/CharacterBody2D.position
	var diff = player_pos - b_pos
	success_timer += delta
	if(diff.length() > inner_radius and diff.length()<outer_radius):
		$inner_radius.set_default_color(Color.GREEN)
		$outer_radius.set_default_color(Color.GREEN)
		
	else:
		success_timer = 0
		$inner_radius.set_default_color(Color.RED)
		$outer_radius.set_default_color(Color.RED)
	
	
	if success_timer>20:
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
	
	##check for success
	check_linepath(_delta)
	var cont = Input.is_action_just_pressed("continue")
	if success:
		var suc_label = $Ship_Scene/CanvasLayer/Success
		
		if !suc_label.get_is_on():
			suc_label.turn_on()
			
		if cont:
			get_tree().change_scene_to_file("res://Scenes/level_2.tscn")
	else:
		var instr = $Ship_Scene/CanvasLayer/instructutions
		if instr.get_is_on():
			if cont:
				instr.turn_off()
