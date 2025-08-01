class_name Orbiting_Body
extends RigidBody2D

var radius: float = 1.0

func _ready() -> void:
	self.mass = 1.0
	self.gravity_scale = 0
	self.radius = 0.0
	self.linear_damp = 0
	self.angular_damp = 0
	self.angular_velocity = 0.0
	self.linear_velocity = Vector2(0,0)
	self.position = Vector2(0,0)

func _update_scale():
	$Sprite2D.scale = Vector2.ONE * self.radius
	$CollisionShape2D.shape.radius = radius

func create_orbiting_body(mass_ : float, radius_ : float, 
init_pos_ = Vector2(0,0), init_vel_ = Vector2(0,0), omega_ = 0) -> Orbiting_Body:
	var new_body : Orbiting_Body
	new_body.mass = mass_
	new_body.radius = radius_
	new_body._update_scale()
	new_body.angular_velocity = omega_
	new_body.position = init_pos_
	new_body.linear_velocity = init_vel_
	return new_body

func _physics_process(delta: float) -> void:
	self.linear_velocity = Vector2(0.0,0.0)
	var collision_info = move_and_collide(self.linear_velocity*delta)
	if collision_info:
		pass
