extends Node2D

@export var a_scale = 0

var LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE = 1
var ANGULAR_THRUST_TO_FUEL_CONSUMPTION = 0.01

var thrust_scale = 1
var thrust_scale_rotate = 0.01
const mass = Constants.ship_mass
var gravity = Vector2(0,1)*a_scale
var calc_forces = true
var main_thrust = 0*thrust_scale
var thrust_rotate = 0.0*thrust_scale_rotate
var thrust_int: int = 0
var max_thrust_int: int = 20
var orientation = Vector2(0,-1)
var angular_vel = 0.0
var bods = []
var line: Line2D
var fuel_consumed_accumulator = 0

var alignment_mode_status = 0
var alignment_is_rotating = false 

var animation_thrust_vect: Vector2i = Vector2i(0,0)
var transition_animation: bool = false


const throttle_speed = 25
var held_time = 0
var max_hold_time=0.5
var thrust_add =0

const def_dead_speed=100
const oriented_dead_spead=1
var ship_exploded_time=0

var change_orb_potent=false
var is_booster_on = false
var is_booster_on_previous = false

#zoom items
var zoomup = false
var zoomdown = false
var velocity_zoom = true

var dt_int = 0.005
var show_path=true

#sound items
var sound_player_explosion = AudioStreamPlayer.new()	# Explosion sound
var sound_player_rocket_booster = AudioStreamPlayer.new()	# Booster sound
var sound_player_fuel_low_warning = AudioStreamPlayer.new()	# Fuel low warning
var sound_player_generic_button_pressed = AudioStreamPlayer.new()
var fuel_low_warning_on = false
var shhhhh = true


func _ready() -> void:
	$CharacterBody2D/Camera2D.make_current()
	$CharacterBody2D/CollisionPolygon2D.scale = $CharacterBody2D/CollisionPolygon2D.scale*Constants.ship_size
	$CharacterBody2D/Sprite2D.scale = $CharacterBody2D/Sprite2D.scale*Constants.ship_size
	$CharacterBody2D/CollisionPolygon2D.position -= Vector2(1,29)*Constants.ship_size
	#sound items
	sound_player_explosion.stream = preload("res://Scenes/Explosion.wav")
	sound_player_explosion.volume_db = -10
	add_child(sound_player_explosion)
	sound_player_rocket_booster.stream = preload("res://Scenes/Rocket_booster.wav")
	sound_player_rocket_booster.volume_db = -5
	add_child(sound_player_rocket_booster)
	sound_player_fuel_low_warning.stream = preload("res://Scenes/Fuel_low_warning.wav")
	sound_player_fuel_low_warning.volume_db = -5
	add_child(sound_player_fuel_low_warning)
	sound_player_generic_button_pressed.stream = preload("res://Scenes/generic_button_sound.wav")
	sound_player_generic_button_pressed.volume_db = -5
	add_child(sound_player_generic_button_pressed)
	
func set_current_animation():
	var cur_an = $CharacterBody2D/Sprite2D.animation
	var sprite: AnimatedSprite2D = $CharacterBody2D/Sprite2D
	var sprite_string = str(animation_thrust_vect.x)+"_"+str(animation_thrust_vect.y)
	var current_sprite_vector = Vector2i(int(str(cur_an).split("_")[0]),int(str(cur_an).split("_")[1]))
	if transition_animation:
		transition_animation = false
		current_sprite_vector = Vector2i(0,0)
	if (animation_thrust_vect.y == 1 or animation_thrust_vect.y ==0) and current_sprite_vector.y==-1:
		sprite.play_backwards('0_-1')
		transition_animation= true
	elif(current_sprite_vector.y == -1 and current_sprite_vector.x != 0 ) and (animation_thrust_vect.y == -1 and animation_thrust_vect.x ==0):
		sprite.play(sprite_string)
		sprite.set_frame_and_progress(2,1)
	else:
		if cur_an != sprite_string:
			sprite.play(sprite_string)
	
	
func rotate_ship(direct:String,modified_rotation=1):
	if $CanvasLayer/FuelBar.out_of_fuel() == false:
		if direct=='right':
			$CharacterBody2D.rotation += 0.1*modified_rotation
			fuel_consumed_accumulator += ANGULAR_THRUST_TO_FUEL_CONSUMPTION*modified_rotation
			decrement_fuel()
			animation_thrust_vect.x = 1
		elif direct=='left':	
			$CharacterBody2D.rotation -= 0.1*modified_rotation
			fuel_consumed_accumulator += ANGULAR_THRUST_TO_FUEL_CONSUMPTION*modified_rotation
			decrement_fuel()
			animation_thrust_vect.x = -1
		elif(direct=='stop'):
			animation_thrust_vect.x = 0
		
func get_input(delta):
	var up = Input.is_action_just_pressed('up')
	var down = Input.is_action_just_pressed('down')
	var left = Input.is_action_pressed('left')
	var right = Input.is_action_pressed('right')
	var scroll_up = Input.is_action_just_released("zoom_in")
	var scroll_down = Input.is_action_just_released("zoom_out")
	var mid_mouse = Input.is_action_just_pressed("vel_zoom")
	var left_up = Input.is_action_just_released('left')
	var right_up = Input.is_action_just_released('right')
	var up_pressed = Input.is_action_pressed('up')
	var down_pressed = Input.is_action_pressed('down')
	var up_up = Input.is_action_just_released('up')
	var down_down = Input.is_action_just_released('down')
	var restart = Input.is_action_just_pressed('restart')
	var align_pressed = Input.is_action_just_pressed("alignment_toggle_mode")
	var change_orb_pot = Input.is_action_just_pressed("change_orb_pot")
	
	
	var cur_animation = $CharacterBody2D/Sprite2D.animation
	
	if align_pressed:
		alignment_mode_status += 1
		if alignment_mode_status>3:
			alignment_mode_status=0
			
		if alignment_mode_status==0:
			rotate_ship("stop")
		
	if change_orb_pot:
		change_orb_potent = true
	
	if restart:
		## Remove sound components before restart level
		
		stop_all_sounds()
		get_tree().reload_current_scene()
		
			
	
	if mid_mouse:
		velocity_zoom = !velocity_zoom
	if scroll_up:
		zoomup=true
	if scroll_down:
		zoomdown=true
		
	if up:
		thrust_int +=1
		
	if down:
		thrust_int -=1
		
	if up_pressed and !up:
		held_time += delta
		if(held_time >= max_hold_time):
			thrust_add += delta*throttle_speed
			thrust_int +=int(thrust_add)
			if thrust_add > 1:
				thrust_add = 0
	if down_pressed and !down:
		held_time += delta
		if(held_time >= max_hold_time):
			thrust_add += delta*throttle_speed
			thrust_int -=int(thrust_add)
			if thrust_add > 1:
				thrust_add = 0
	
		
	thrust_int = clampi(thrust_int,-max_thrust_int,max_thrust_int)
	
	if thrust_int >0:
		animation_thrust_vect.y = 1
	elif thrust_int <0:
		animation_thrust_vect.y = -1
	else:
		animation_thrust_vect.y = 0

	main_thrust = thrust_int*thrust_scale
	
	if right:
		rotate_ship('right')
	if left:
		rotate_ship('left')

	if left_up:
		animation_thrust_vect.x = 0
	if right_up:
		animation_thrust_vect.x = 0
	
	if up_up or down_down:
		held_time=0
		thrust_add=0
	
	
func cal_fg(bodies,pos,m) -> Vector2:
	var force = Vector2(0,0)
	for b in bodies:
		var direction = b.get_pos() - pos
		var distance = direction.length()
		if distance <= 1e-1:
			print("fuck")
			return Vector2.ZERO ## Safeguard
		var force_magnitude = Constants.G * b.get_mass() * m / (distance*distance)
		force += direction.normalized() * force_magnitude
	return force/m
	
func calculate_gravitational_force(bodies) -> Vector2:
	return cal_fg(bodies,$CharacterBody2D.position,self.mass) 
	
func get_bods():
	var bs = get_parent().get_node("Planets").get_children()
	for b in bs:
		bods.append(b)
	return bods
	
func get_xn1(fg,v0,x0):
	var vn1 = v0 + fg*self.dt_int/self.mass
	var xn1 = vn1*self.dt_int + x0 
	return xn1

func get_trajectory(total_t=8):
	var t = 0
	var xn1=$CharacterBody2D.position
	var vn1 = $CharacterBody2D.velocity
	var trajectory = []
	while(t<total_t):
		var fg = cal_fg(bods,xn1,vn1)
		fg = clamp(fg.length(),0,1e3/self.mass)*fg.normalized()
		vn1 += self.dt_int*fg
		xn1 = get_xn1(fg,vn1,xn1)		
		t += self.dt_int
		trajectory.append(xn1)
	return trajectory

func trajectory_draw(trajectory):
	for i in range(0,len(trajectory),50):
		var p = trajectory[i]
		line.add_point(p)
	
func check_ship(col_info: KinematicCollision2D):
	#this doesn't work as well as I would hope
	var col_loc = col_info.get_position()
	var col_to_ship = $CharacterBody2D.position - col_loc
	col_to_ship = col_to_ship.normalized()
	var angle_to_y = acos(col_to_ship.dot(Vector2(0,-1)))
	var angle_in_deg = rad_to_deg(angle_to_y)
	var ship_angle = rad_to_deg($CharacterBody2D.rotation)
	if abs(ship_angle - angle_in_deg) <75:
		return false
	else:
		return true

func explode_ship(delta):
	var ship_sprite:AnimatedSprite2D = $CharacterBody2D/Sprite2D
	var explosion_sprite:AnimatedSprite2D = $CharacterBody2D/explosion
	calc_forces = false
	ship_exploded_time += delta
	get_parent().get_node("KillDeserters/Alien").linear_velocity = Vector2.ZERO
	get_parent().get_node("KillDeserters/Alien").acceleration =0.0
	if explosion_sprite.visible == false:
		explosion_sprite.visible=true
		if !shhhhh:
			explosion_sprite.play('default')
			sound_player_explosion.play()		## play sound
			await get_tree().create_timer(2.0).timeout	
			sound_player_explosion.stop()		## stop sound
		
	if ship_exploded_time > 1.5:
		if $CanvasLayer/RestartText.visible == false:
			$CanvasLayer/RestartText.visible = true
		if ship_sprite.visible:
			ship_sprite.visible = false
			get_parent().get_node("KillDeserters/Alien").visible = false
	if ship_exploded_time > 5:
		if explosion_sprite.visible:
			explosion_sprite.visible = false
			


func alignment_mode_update(delta):
	if $CharacterBody2D.velocity.length() < 0.1:
		rotate_ship('stop')
		alignment_is_rotating = false
		return
	
	var sprite_angle_offset = 0
	if alignment_mode_status==2:
		sprite_angle_offset = PI/2
	if alignment_mode_status==3:
		sprite_angle_offset = 3*PI/2
	var current_vel_angle = Vector2.UP.angle_to($CharacterBody2D.velocity.normalized()) + sprite_angle_offset
	var current_sprite_angle = $CharacterBody2D.rotation
	var diff_angle = angle_difference(current_vel_angle, current_sprite_angle)
	var diff_angle_deg = rad_to_deg(abs(diff_angle))
	
	var angle_threshold = 8     
	var buffer_threshold = 2      
	var rotation_speed = 10
	
	if diff_angle_deg > angle_threshold:
		alignment_is_rotating = true
	elif diff_angle_deg < buffer_threshold:
		alignment_is_rotating = false
	
	if alignment_is_rotating:
		if diff_angle > 0:
			rotate_ship('left', delta * rotation_speed)
		else:
			rotate_ship('right', delta * rotation_speed)
	else:
		rotate_ship('stop')
	
	

func _physics_process(delta: float) -> void:
	if line == null:
		line = self.get_parent().get_node("linepath")
	line.clear_points()
		
	if change_orb_potent:
		for b in bods:
			b.draw_pot = !b.draw_pot
		change_orb_potent = false
		
	get_bods()
	get_input(delta)
	
	set_current_animation()
	$CanvasLayer/ThrustBar.set_thrust(thrust_int)
	
	if ship_exploded_time>0:
		explode_ship(delta)
		
	
	if alignment_mode_status!=0:
		alignment_mode_update(delta)
	
	if calc_forces:
		gravity = calculate_gravitational_force(bods)
		
		var ts = get_trajectory()
		trajectory_draw(ts)
		
		$CharacterBody2D.velocity += delta*(gravity + (main_thrust*Vector2(sin($CharacterBody2D.rotation),-cos($CharacterBody2D.rotation))))
	
	bods = []
	
		# Booster sound on/off
	if animation_thrust_vect.length() > 0:
		is_booster_on = true
		if is_booster_on != is_booster_on_previous:
			if !shhhhh:
				sound_player_rocket_booster.play()
		is_booster_on_previous = is_booster_on
	else:
		is_booster_on = false
		if is_booster_on != is_booster_on_previous:
			sound_player_rocket_booster.stop()
		is_booster_on_previous = is_booster_on

	
	
	
	#camera_items
	if zoomup and velocity_zoom == false:
		zoomup=false
		$CharacterBody2D/Camera2D.zoom = clamp($CharacterBody2D/Camera2D.zoom, Constants.MinZoom, Constants.MaxZoom) + Constants.ZoomSpeed*delta
		
	if zoomdown and velocity_zoom == false:
		zoomdown=false
		$CharacterBody2D/Camera2D.zoom= clamp($CharacterBody2D/Camera2D.zoom, Constants.MinZoom, Constants.MaxZoom) - Constants.ZoomSpeed*delta
	if velocity_zoom:
		var v_l = $CharacterBody2D.velocity
		$CharacterBody2D/Camera2D.zoom = (Constants.MaxZoom*(1 - Constants.vel_zoom_fudge*v_l.length())).clamp(Constants.MinZoom,Constants.MaxZoom)
	
	var collision_info: KinematicCollision2D = $CharacterBody2D.move_and_collide($CharacterBody2D.velocity*delta)
	if collision_info:
		#print("speed: " + str($CharacterBody2D.velocity.length()))
		if $CharacterBody2D.velocity.length() > def_dead_speed:
			explode_ship(delta)
		else:
			var expship = check_ship(collision_info)
			if expship:
				explode_ship(delta)
		#basic collision for now. needs logic
		$CharacterBody2D.velocity = Vector2(0,0)
		
		
	fuel_consumed_accumulator += LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE*abs(thrust_int)*delta
	decrement_fuel()
	
	
		

func decrement_fuel() -> void:
	
	if fuel_consumed_accumulator > 1:
		fuel_consumed_accumulator = 0
		$CanvasLayer/FuelBar.reduce()
	if $CanvasLayer/FuelBar.out_of_fuel():
		thrust_int = 0
		$CanvasLayer/ThrustBar.set_thrust(thrust_int)
		$CanvasLayer/ThrustBar.deactivate()
	if $CanvasLayer/FuelBar.fuel < Constants.fuel_low_warning and fuel_low_warning_on == false:
		fuel_low_warning_on = true;
		if !shhhhh:
			sound_player_fuel_low_warning.play()
func stop_all_sounds() -> void:
	sound_player_explosion.stop()
	sound_player_rocket_booster.stop()
	sound_player_fuel_low_warning.stop()
	
