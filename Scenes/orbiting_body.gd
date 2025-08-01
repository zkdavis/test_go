class_name Orbiting_Body
extends Node2D

var radius: float = 1.0
@onready var body := $RigidBody2D

func _ready() -> void:
	body.mass = 1.0
	body.gravity_scale = 0
	radius = 1.0
	body.linear_damp = 0
	body.angular_damp = 0
	body.angular_velocity = 0.0
	body.linear_velocity = Vector2(0,0)
	body.position = Vector2(0,0)

func _update_scale():
	$RigidBody2D/Sprite2D.scale = Vector2.ONE * self.radius
	$RigidBody2D/CollisionShape2D.shape.radius = radius

func setup(mass_ : float, radius_ : float, 
init_pos_ = Vector2(0,0), init_vel_ = Vector2(0,0), omega_ = 0) -> void:
	body.mass = mass_
	self.radius = radius_
	self._update_scale()
	body.angular_velocity = omega_
	body.position = init_pos_
	body.linear_velocity = init_vel_

func get_mass() -> float:
	return body.mass

func get_pos() -> Vector2:
	return body.position

func get_radius() -> float:
	return radius
	
func get_omega() -> float:
	return body.angular_velocity
	
func apply_force(f : Vector2) -> void:
	body.apply_central_force(f)

func _physics_process(delta: float) -> void:
	body.move_and_collide(body.linear_velocity)
