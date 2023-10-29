extends Button

var min_alpha = 0.6  # Minimum alpha value (dim)
var max_alpha = 1.0  # Maximum alpha value (glow)
var speed = 0.5  # Adjust the speed (higher value = faster)

var is_dimming = true
var current_alpha = 1.0

func _process(delta:float) -> void:
	if is_dimming:
		current_alpha = max(min_alpha, current_alpha - speed * delta)
		if current_alpha <= min_alpha:
			is_dimming = false
	else:
		current_alpha = min(max_alpha, current_alpha + speed * delta);
		if current_alpha >= max_alpha:
			is_dimming = true
			
	self.modulate.a = current_alpha;

