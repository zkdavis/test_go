extends RigidBody2D

const ACCELERATION = 10.0
const SPEED = 200.0
var ship_position : Vector2 = Vector2(1.0,0.0)
var activated : bool
var speed_accumulator = 0.0

func _ready() -> void:
	self.mass = 1.0
	self.gravity_scale = 0
	self.linear_damp = 0
	self.angular_damp = 0
	self.angular_velocity = 0.0
	self.linear_velocity = Vector2(0,0)
	self.position = Vector2(INF, INF)
	activated = false
	
func reset_alien(radius : float) -> void:
	self.position = Vector2(0, -radius)

func store_ship_position(pos : Vector2) -> void:
	ship_position = pos

func activate_ship() -> void:
	self.activated = true
	self.position = 2*ship_position
	speed_accumulator = SPEED
	print("activated!")

func _physics_process(delta: float) -> void:
	var diff = ship_position - position
	speed_accumulator += ACCELERATION*delta
	self.linear_velocity = speed_accumulator*diff.normalized()
	var angle = atan2(diff.x, -diff.y)
	while angle <= -PI:
		angle += 2*PI
	while angle > PI:
		angle -= 2*PI
	global_rotation = angle
