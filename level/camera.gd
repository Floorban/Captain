extends Camera2D
class_name MultiTargetCamera

@export var targets: Array[Node2D] = []
@export var smooth_speed: float = 3.0
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_limit_distance: float = 100.0

func _physics_process(delta: float) -> void:
	if targets.is_empty():
		return
	
	for t in targets:
		if not is_instance_valid(t):
			return
	
	# --- calculate average position of all targets ---
	var center := Vector2.ZERO
	var valid_targets := 0
	for target in targets:
		if is_instance_valid(target):
			center += target.global_position
			valid_targets += 1
	if valid_targets == 0:
		return
	
	center /= valid_targets
	
	# --- move camera to center point ---
	global_position = global_position.lerp(center, delta * smooth_speed)
	
	# --- bounding box / distance between targets ---
	var min_pos = targets[0].global_position
	var max_pos = targets[0].global_position
	for target in targets:
		if is_instance_valid(target):
			min_pos = min_pos.min(target.global_position)
			max_pos = max_pos.max(target.global_position)
	
	var distance = min_pos.distance_to(max_pos)
	
	# --- zoom based on distance between targets ---
	var zoom_factor = lerp(min_zoom, max_zoom, clamp(zoom_limit_distance / distance, 0.0, 1.0))
	zoom = zoom.lerp(Vector2(zoom_factor, zoom_factor), delta * smooth_speed)
