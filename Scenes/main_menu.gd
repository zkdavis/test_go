extends Node2D


var radius_of_moon = 800
var outer_radius = 1.5*radius_of_moon
var inner_radius = 1.3*radius_of_moon
var success_timer = 0
var success:bool = false

var ob_scene : PackedScene = load("res://Scenes/orbiting_body.tscn")

func calculate_circular_orbit_location(vel: Vector2,m: float):
	return Constants.G*m/(vel.length()**2)


func next_scene():
	get_tree().change_scene_to_file("res://Scenes/orbit_level.tscn")

func prev_scene():
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ship_Scene.rescale_ship(1)
	$Ship_Scene.change_thrust_scale(1)
	
	
	
	var mass_moon  = 10000
	$KillDeserters.adjust_radii(radius_of_moon*8,radius_of_moon*11)
	
	var center = Vector2(get_window().size.x,get_window().size.y)/2

	
	var player_velocity = Vector2.ZERO
	var player_postion =Vector2(center.x,center.y) - Vector2(0,1*radius_of_moon) 
	
	$Ship_Scene/CharacterBody2D.position = player_postion
	$Ship_Scene/CharacterBody2D.velocity = player_velocity
	$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE = 0.2*$Ship_Scene.LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE
	$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION = 0.2*$Ship_Scene.ANGULAR_THRUST_TO_FUEL_CONSUMPTION
	$linepath.width = 3
	

	$Ship_Scene.get_node("CharacterBody2D/Camera2D").zoom=Vector2(0.8,0.8)
	
	$Start.position = player_postion
	$Start.position.x += 500
	
	$Credits.position = player_postion
	$Credits.position.x -= 800
	
	#$Start/CollisionShape2D.scale = Vector2.ONE*10
	#$Start/CollisionShape2D.scale = Vector2.ONE*10
	#
	var instr = $Ship_Scene/CanvasLayer/instructutions
	#if !instr.get_is_on():
		#instr.turn_on()
		

	

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
	
	##check for success
	var cont = Input.is_action_just_pressed("continue")
	if success:
		var suc_label = $Ship_Scene/CanvasLayer/Success
		
		if !suc_label.get_is_on():
			suc_label.turn_on()
			
		if cont:
			get_tree().reload_current_scene()
	else:
		var instr = $Ship_Scene/CanvasLayer/instructutions
		if instr.get_is_on():
			if cont:
				instr.turn_off()
