extends Node

## Function for more accurate interpolation
func damp(source, target, smoothing, dt):
	return lerp(source, target, 1 - exp(-smoothing * dt))
