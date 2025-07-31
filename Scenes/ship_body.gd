extends CharacterBody2D

@export var a_scale = 10000
@export var thrust_scale = 10
@export var thrust_scale_rotate = 0.1

var gravity = Vector2(0,1)*a_scale
var main_thrust = 0*thrust_scale
var thrust_rotate = 0.0*thrust_scale_rotate
var thrust = 0
var orientation = Vector2(0,-1)
var angular_vel = 0.0

func _ready() -> void:
	self.position = get_window().size/2
	self.position.y +=100
	#self.rotation = PI/2

func get_input():
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')
	var left = Input.is_action_pressed('ui_left')
	var right = Input.is_action_pressed('ui_right')

	if up:
		main_thrust += 1*thrust_scale
	if down:
		main_thrust += -1*thrust_scale
	if right:
		self.rotation += 0.01
		#thrust_rotate += clamp(1.0*thrust_scale_rotate,-3*thrust_scale_rotate,3*thrust_scale_rotate)
	if left:
		self.rotation -= 0.01
		#thrust_rotate += clamp(-1.0*thrust_scale_rotate,-3*thrust_scale_rotate,3*thrust_scale_rotate)
		
func _physics_process(delta: float) -> void:
	get_input()
	thrust = main_thrust
	#apply rotation to thrust
	var w_size = get_window().size/2
	var center_r = self.position - Vector2(w_size[0],w_size[1])
	if center_r.length() > 2:
		gravity = -a_scale*center_r/(center_r.length()**(5/2))
	else:
		gravity = Vector2(0,0)
	self.velocity += delta*(gravity + (thrust*Vector2(sin(self.rotation),-cos(self.rotation))))
	
	self.angular_vel += thrust_rotate*delta
	self.rotate(self.angular_vel*delta)
	if(abs(self.angular_vel) < 2*delta*thrust_scale_rotate and abs(self.thrust_rotate)<3*thrust_scale_rotate ):
		self.angular_vel*=exp(-3*delta)
		self.thrust_rotate=0
		if(abs(self.angular_vel) < 0.5*thrust_scale_rotate*delta):
			self.angular_vel =0
			if rotation <0.0001:
				rotation = 0
			
	var collision_info = move_and_collide(self.velocity*delta)
	if collision_info:
		
		#basic collision for now. needs logic
		self.velocity = Vector2(0,0)
		
		
