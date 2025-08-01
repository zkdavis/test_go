class_name Orbiting_Body
extends Node2D

var radius: float = 1.0
const MAGIC_FUDGE_FACTOR_DUE_TO_IMAGE_SIZE = 20
@onready var body := $"Planet Physics Body"

func _ready() -> void:
	body.mass = 1.0
	body.gravity_scale = 0
	radius = 1.0
	body.linear_damp = 0
	body.angular_damp = 0
	body.angular_velocity = 0.0
	body.linear_velocity = Vector2(0,0)
	body.position = Vector2(0,0)
	body.custom_integrator = true
	body.set_use_custom_integrator(true)

func _update_scale(radius_):
	$"Planet Physics Body"/Sprite2D.scale = Vector2.ONE*radius_
	$"Planet Physics Body"/CollisionShape2D.shape.radius = MAGIC_FUDGE_FACTOR_DUE_TO_IMAGE_SIZE*radius_

func setup(mass_ : float, radius_ : float, 
init_pos_ = Vector2(0,0), init_vel_ = Vector2(0,0), omega_ = 0) -> void:
	body.mass = mass_
	self.radius = radius_
	_update_scale(radius_)
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
	
func clear_force():
	body.force = Vector2.ZERO

func apply_force(f : Vector2) -> void:
	body.force += f
