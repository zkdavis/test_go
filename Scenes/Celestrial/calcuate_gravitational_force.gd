func calculate_gravitational_force(location1: Vector2, location2: Vector2, mass1: float, mass2: float) -> Vector2:
	var G = 6.674e-11 ## GConstant
	var direction = location1 - location2
	var distance = direction.length()
	if distance == 0:
		return Vector2.ZERO ## Safeguard
	var force_magnitude = G * mass1 * mass2 / pow(distance, 2)
	return direction.normalized() * force_magnitude
