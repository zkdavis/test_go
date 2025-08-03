class_name Orbiting_Body
extends Node2D

var draw_pot: bool = false
var radius: float = 1.0
const MAKE_PIXELS_BIGGER = 75
const RED = Color(0.933333,0.615686,0.58039, 1.0)
const ORANGE = Color(0.976470,0.796078,0.647058, 1.0)
const YELLOW = Color(0.968627, 0.9372549, 0.505882, 1.0)
const GREEN = Color(0.709803,0.854901,0.72941, 1.0)
const BLUE = Color(0.596078,0.780392,0.917647, 1.0)
const PURPLE = Color(0.647058, 0.580392, 0.976470, 1.0)
const GREY = Color(0.701960,0.780392,0.772549, 1.0)

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
	body.z_index=0

func _draw():
	if(draw_pot):
		var center = body.position		## Import the position of a rigid body
		var ring_count: int = 100  ## Ring segments
		var max_radius = body.mass * 0.5

		for i in range(ring_count):
			var inner_r = max_radius * i / ring_count
			var outer_r = max_radius * (i + 1) / ring_count

			var inner_points = []
			var outer_points = []
			var segments = 64  ## Circle resolution

			for j in range(segments):
				var angle = TAU * j / segments
				inner_points.append(center + Vector2(cos(angle), sin(angle)) * inner_r)
				outer_points.append(center + Vector2(cos(angle), sin(angle)) * outer_r)

			var hue = lerp(0.5, 1.0, float(i) / ring_count)
			var color = Color.from_hsv(hue, 1.0, 1.0,0.1)

			for j in range(segments):
				var p1 = inner_points[j]
				var p2 = outer_points[j]
				var p3 = outer_points[(j + 1) % segments]
				var p4 = inner_points[(j + 1) % segments]

				draw_polygon([p1, p2, p3, p4], [color, color, color, color])

func _update_scale(radius_) -> void:
	var sprite_radius = get_node("Planet Physics Body/Sprite2D").texture.get_size().x/2
	get_node("Planet Physics Body/Sprite2D").scale = Vector2.ONE*(radius_/sprite_radius)*MAKE_PIXELS_BIGGER
	get_node("Planet Physics Body/CollisionShape2D").shape.radius = radius_*MAKE_PIXELS_BIGGER


func setup(mass_ : float, radius_ : float, 
init_pos_ = Vector2(0,0), init_vel_ = Vector2(0,0), omega_ = 0) -> void:
	body.mass = mass_
	self.radius = radius_
	var collision_shape = body.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
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

func set_color(r : float, g : float, b : float) -> void:
	self.get_node("Planet Physics Body/Sprite2D").self_modulate = Color(r, g, b, 1.0)
	self.z_index = 1
	self.visibility_layer = 1

func set_color_direct(c : Color) -> void:
	self.get_node("Planet Physics Body/Sprite2D").self_modulate = c
	self.z_index = 1
	self.visibility_layer = 1

func set_red() -> void:
	set_color_direct(RED)

func set_orange() -> void:
	set_color_direct(ORANGE)

func set_yellow() -> void:
	set_color_direct(YELLOW)

func set_green() -> void:
	set_color_direct(GREEN)

func set_blue() -> void:
	set_color_direct(BLUE)

func set_purple() -> void:
	set_color_direct(PURPLE)

func set_grey() -> void:
	set_color_direct(GREY)
