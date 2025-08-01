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

@export var max_radius: float = 100.0

func _draw():
	var center = self.position		## Import the position of a rigid body
	var ring_count: int = 100  ## Ring segments
	var max_radius = self.mass * 100

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

		var hue = lerp(0.0, 0.33, float(i) / ring_count)
		var color = Color.from_hsv(hue, 1.0, 1.0)

		for j in range(segments):
			var p1 = inner_points[j]
			var p2 = outer_points[j]
			var p3 = outer_points[(j + 1) % segments]
			var p4 = inner_points[(j + 1) % segments]

			draw_polygon([p1, p2, p3, p4], [color, color, color, color])

	

func _physics_process(delta: float) -> void:
	self.linear_velocity = Vector2(0.0,0.0)
	var collision_info = move_and_collide(self.linear_velocity*delta)
	if collision_info:
		pass
