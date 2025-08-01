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
var bods = []



func get_input():
	var up = Input.is_action_just_pressed('ui_up')
	var down = Input.is_action_just_pressed('ui_down')
	var left = Input.is_action_pressed('ui_left')
	var right = Input.is_action_pressed('ui_right')

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
	$CharacterBody2D.rotate(self.angular_vel*delta)
	##if(abs(self.angular_vel) < 2*delta*thrust_scale_rotate and abs(self.thrust_rotate)<3*thrust_scale_rotate ):
		##self.angular_vel*=exp(-3*delta)
		##self.thrust_rotate=0
		##if(abs(self.angular_vel) < 0.5*thrust_scale_rotate*delta):
			##self.angular_vel =0
			##if rotation <0.0001:
				##rotation = 0
			##
	var collision_info = $CharacterBody2D.move_and_collide($CharacterBody2D.velocity*delta)
	if collision_info:
		#basic collision for now. needs logic
		$CharacterBody2D.velocity = Vector2(0,0)
		
		
