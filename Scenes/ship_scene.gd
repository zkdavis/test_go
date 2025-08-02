extends Node2D

@export var a_scale = 0
@export var thrust_scale = 50
@export var thrust_scale_rotate = 0.01
@export var mass = 1

const LINEAR_THRUST_TO_FUEL_CONSUMPTION_RATE = 1
const ANGULAR_THRUST_TO_FUEL_CONSUMPTION = 0.01


var gravity = Vector2(0,1)*a_scale
var main_thrust = 0*thrust_scale
var thrust_rotate = 0.0*thrust_scale_rotate
var thrust_int: int = 0
var max_thrust_int: int = 20
var orientation = Vector2(0,-1)
var angular_vel = 0.0
var alignment_mode_status = false
var bods = []
var line: Line2D
var fuel_consumed_accumulator = 0


#zoom items
@export var vel_zoom_fudge = 0.001
var ZoomSpeed = Vector2(5,5)
var MinZoom = Vector2(0.4, 0.4)
var MaxZoom = Vector2(1,1)
var zoomup = false
var zoomdown = false
var velocity_zoom = true

var dt_int = 0.003

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
	if down:
		thrust_int -=1
		thrust_int = clampi(thrust_int,-max_thrust_int,max_thrust_int)

	main_thrust = thrust_int*thrust_scale
	
	if right:
		if thrust_scale != 0:
			$CharacterBody2D.rotation += 0.1
			fuel_consumed_accumulator += ANGULAR_THRUST_TO_FUEL_CONSUMPTION
			decrement_fuel()
			#thrust_rotate += clamp(1.0*thrust_scale_rotate,-3*thrust_scale_rotate,3*thrust_scale_rotate)
	if left:
		if thrust_scale != 0:
			$CharacterBody2D.rotation -= 0.1
			fuel_consumed_accumulator += ANGULAR_THRUST_TO_FUEL_CONSUMPTION
			decrement_fuel()
			#thrust_rotate += clamp(-1.0*thrust_scale_rotate,-3*thrust_scale_rotate,3*thrust_scale_rotate)
		
func cal_fg(bodies,pos,m) -> Vector2:
	var G = 10000 ## GConstant
	var force = Vector2(0,0)
	for b in bodies:
		var direction = b.get_pos() - pos
		var distance = direction.length()
		if distance <= 1e-1:
			print("fuck")
			return Vector2.ZERO ## Safeguard
		var force_magnitude = G * b.get_mass() * m / (distance*distance)
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
		vn1 += self.dt_int*fg
		xn1 = get_xn1(fg,vn1,xn1)		
		t += self.dt_int
		trajectory.append(xn1)
	return trajectory

func trajectory_draw(trajectory):
	for i in range(0,len(trajectory),50):
		var p = trajectory[i]
		line.add_point(p)
	
func _physics_process(delta: float) -> void:
	if line == null:
		line = self.get_parent().get_node("linepath")
	line.clear_points()
		
	get_bods()
	get_input()
	$CanvasLayer/ThrustBar.set_thrust(thrust_int)
	
	gravity = calculate_gravitational_force(bods)
	
	var ts = get_trajectory()
	trajectory_draw(ts)
	
	bods = []
	$CharacterBody2D.velocity += delta*(gravity + (main_thrust*Vector2(sin($CharacterBody2D.rotation),-cos($CharacterBody2D.rotation))))
	#self.angular_vel += thrust_rotate*delta
	if alignment_mode_status:	## Check alignment mode
		var sprite_angle_offset = PI/2	## Sprite offset angle
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
		$CharacterBody2D/Camera2D.zoom = (MaxZoom*(1 - vel_zoom_fudge*v_l.length())).clamp(MinZoom,MaxZoom)

		
	
	var collision_info = $CharacterBody2D.move_and_collide($CharacterBody2D.velocity*delta)
	if collision_info:
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
		thrust_scale = 0
		$CanvasLayer/ThrustBar.set_thrust(thrust_int)
		$CanvasLayer/ThrustBar.deactivate()
