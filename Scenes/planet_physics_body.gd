extends RigidBody2D

var force : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	custom_integrator = true
	set_use_custom_integrator(true)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var delta = state.get_step()
	self.linear_velocity += (force/self.mass)*delta
