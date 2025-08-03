extends RigidBody2D

const ACCELERATION = 10.0
const SPEED = 150.0
var ship_position : Vector2 = Vector2(1.0,0.0)
var activated : bool

func _ready() -> void:
	self.mass = 1.0
	self.gravity_scale = 0
	self.linear_damp = 0
	self.angular_damp = 0
	self.angular_velocity = 0.0
	self.linear_velocity = Vector2(0,0)
	self.position = Vector2(INF, INF)
	activated = false
	self.custom_integrator = true
	self.set_use_custom_integrator(true)
	
func reset_alien(radius : float) -> void:
	self.position = Vector2(0, -radius)

func store_ship_position(pos : Vector2) -> void:
	ship_position = pos

func activate_ship() -> void:
	activated = true
	position = 2*ship_position

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if activated:
		var delta = state.get_step()
		var diff = ship_position - position
		self.linear_velocity = SPEED*(1.0 + (ACCELERATION/self.mass)*delta)*diff.normalized()
		self.position += self.linear_velocity*delta
		var angle = atan2(diff.x, -diff.y)
		while angle <= -PI:
			angle += 2*PI
		while angle > PI:
			angle -= 2*PI
		global_rotation = angle
