class_name Orbiting_Body
extends Node2D

var draw_pot: bool = true
var radius: float = 1.0
const MAGIC_FUDGE_FACTOR_DUE_TO_IMAGE_SIZE = 10.0/0.625
const RED = Color(0.933333,0.615686,0.58039)
const ORANGE = Color(0.976470,0.796078,0.647058)
const GREEN = Color(0.709803,0.854901,0.72941)
const BLUE = Color(0.596078,0.780392,0.917647)
const GREY = Color(0.701960,0.780392,0.772549)

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

func set_color(r : float, g : float, b : float) -> void:
	get_node("Planet Physics Body/Sprite2D").modulate = Color(r, g, b, 1.0)

func set_red() -> void:
	get_node("Planet Physics Body/Sprite2D").modulate = RED

func set_orange() -> void:
	get_node("Planet Physics Body/Sprite2D").modulate = ORANGE

func set_green() -> void:
	get_node("Planet Physics Body/Sprite2D").modulate = GREEN

func set_blue() -> void:
	get_node("Planet Physics Body/Sprite2D").modulate = BLUE

func set_grey() -> void:
	get_node("Planet Physics Body/Sprite2D").modulate = GREY
