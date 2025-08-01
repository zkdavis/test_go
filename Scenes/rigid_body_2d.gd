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

func setup(mass_ : float, radius_ : float, 
init_pos_ = Vector2(0,0), init_vel_ = Vector2(0,0), omega_ = 0) -> void:
	self.mass = mass_
	self.radius = radius_
	self._update_scale()
	self.angular_velocity = omega_
	self.position = init_pos_
	self.linear_velocity = init_vel_
