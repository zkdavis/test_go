extends CharacterBody2D

@export var a_scale = 100
@export var thrust_scale = 10


var gravity = Vector2(0,1)*a_scale
var thrust = Vector2(0,0)*thrust_scale
var thrust_rotate = Vector2(0,0)*thrust_scale

func _input(event: InputEvent) -> void:
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')
	if up:
		thrust += Vector2(0,-1)*thrust_scale
	if down:
		thrust += Vector2(0,1)*thrust_scale
	
func _physics_process(delta: float) -> void:
	self.velocity += delta*(gravity+thrust)
	#self.position += delta*self.velocity
	var collision_info = move_and_collide(self.velocity*delta)
	
