func calculate_trajectory(
	planet_position: Vector2,
	start_position: Vector2,
	start_velocity: Vector2,
	mass1: float,	## Planet
	mass2: float,	## Ships, stations, etc (oribiting objects)
	steps: int,
	timestep: float = 0.1
) -> Array:
	var position = start_position
	var velocity = start_velocity
	var trajectory: Array = []
## This calcuate a trajectory in run time... this may need optimization
	for i in range(steps):
		## Probably need to make the function static
		var force = calculate_gravitational_force(planet_position, position, mass1, mass2)
		var acceleration = force / mass2

		# Integrate
		velocity += acceleration * timestep
		position += velocity * timestep

		trajectory.append(position)

	return trajectory
