extends Node2D

@export var a_scale = 0
@export var thrust_scale = 50
@export var thrust_scale_rotate = 0.01
@export var mass = 1

var gravity = Vector2(0,1)*a_scale
var main_thrust = 0*thrust_scale
var thrust_rotate = 0.0*thrust_scale_rotate
var thrust_int: int = 0
var max_thrust_int: int = 20
var orientation = Vector2(0,-1)
var angular_vel = 0.0
var alignment_mode_status = false
var bods = []

var ZoomSpeed = Vector2(5,5)
var MinZoom = Vector2(0.4, 0.4)
var MaxZoom = Vector2(1,1)
var zoomup = false
var zoomdown = false
var velocity_zoom = true

## Alignment mode togle on
func _unhandled_input(event):
	if event.is_action_pressed("alignment_toggle_mode"):
		alignment_mode_status = !alignment_mode_status		## Toggle alignment mode

		

func get_input():
	var up = Input.is_action_just_pressed('up')
	var down = Input.is_action_just_pressed('down')
	var left = Input.is_action_pressed('left')
	var right = Input.is_action_pressed('right')
	var scroll_up = Input.is_action_just_released("zoom_in")
	var scroll_down = Input.is_action_just_released("zoom_out")
	var mid_mouse = Input.is_action_just_pressed("vel_zoom")
	
	if mid_mouse:
		velocity_zoom = !velocity_zoom
	if scroll_up:
		zoomup=true
	if scroll_down:
		zoomdown=true
		
	if up:
		thrust_int +=1
		thrust_int = clampi(thrust_int,-max_thrust_int,max_thrust_int)
		self.get_parent().get_node("ThrustGauge/Label2").text = str(thrust_int)
	if down:
		thrust_int -=1
		thrust_int = clampi(thrust_int,-max_thrust_int,max_thrust_int)
		self.get_parent().get_node("ThrustGauge/Label2").text = str(thrust_int)
		
	main_thrust = thrust_int*thrust_scale
	
	if right:
		$CharacterBody2D.rotation += 0.1
		#thrust_rotate += clamp(1.0*thrust_scale_rotate,-3*thrust_scale_rotate,3*thrust_scale_rotate)
	if left:
		$CharacterBody2D.rotation -= 0.1
		#thrust_rotate += clamp(-1.0*thrust_scale_rotate,-3*thrust_scale_rotate,3*thrust_scale_rotate)
		
func calculate_gravitational_force(bodies) -> Vector2:
	var G = 10000 ## GConstant
	var force = Vector2(0,0)
	for b in bodies:
		var direction = b.get_pos() - $CharacterBody2D.global_position
		var distance = direction.length()
		if distance <= 1e-1:
			return Vector2.ZERO ## Safeguard
		var force_magnitude = G * b.get_mass() * self.mass / (distance*distance)
		force += direction.normalized() * force_magnitude
	return force/self.mass
	
func get_bods():
	var bs = get_parent().get_node("Planets").get_children()
	for b in bs:
		bods.append(b)
	return bods
		
		
func _physics_process(delta: float) -> void:
	get_bods()
	get_input()
	
	gravity = calculate_gravitational_force(bods)
	bods = []
	$CharacterBody2D.velocity += delta*(gravity + (main_thrust*Vector2(sin($CharacterBody2D.rotation),-cos($CharacterBody2D.rotation))))
	#self.angular_vel += thrust_rotate*delta
	if alignment_mode_status:	## Check alignment mode
		var sprite_angle_offset = 3.141592/2	## Sprite offset angle
		var current_vel_angle = $CharacterBody2D.velocity.angle() + sprite_angle_offset
		var current_sprite_angle = $CharacterBody2D.rotation
		var diff_angle = current_sprite_angle - current_vel_angle
		var angle_threshold = 0.314;
		if abs(diff_angle) > angle_threshold:	## 10 degrees threshold
			$CharacterBody2D.rotation = current_vel_angle	## if you like interpolate diff angle this should be the right place
		else:
			$CharacterBody2D.rotation = current_vel_angle
	$CharacterBody2D.rotate(self.angular_vel*delta)
	##if(abs(self.angular_vel) < 2*delta*thrust_scale_rotate and abs(self.thrust_rotate)<3*thrust_scale_rotate ):
		##self.angular_vel*=exp(-3*delta)
		##self.thrust_rotate=0
		##if(abs(self.angular_vel) < 0.5*thrust_scale_rotate*delta):
			##self.angular_vel =0
			##if rotation <0.0001:
				##rotation = 0
			##
	
	#camera_items
	if zoomup and velocity_zoom == false:
		zoomup=false
		$CharacterBody2D/Camera2D.zoom = clamp($CharacterBody2D/Camera2D.zoom, MinZoom, MaxZoom) + ZoomSpeed*delta
	if zoomdown and velocity_zoom == false:
		zoomdown=false
		$CharacterBody2D/Camera2D.zoom= clamp($CharacterBody2D/Camera2D.zoom, MinZoom, MaxZoom) - ZoomSpeed*delta
	if velocity_zoom:
		var v_l = $CharacterBody2D.velocity
		$CharacterBody2D/Camera2D.zoom = (MaxZoom*(1 - 0.001*v_l.length())).clamp(MinZoom,MaxZoom)

		
	
	var collision_info = $CharacterBody2D.move_and_collide($CharacterBody2D.velocity*delta)
	if collision_info:
		#basic collision for now. needs logic
		$CharacterBody2D.velocity = Vector2(0,0)
		
		
