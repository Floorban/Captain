extends Camera2D
class_name RadarController

@onready var player: Player = Global.get_captain()
@onready var path: Path2D = $Path2D
@onready var path_follow = $Path2D/PathFollow2D

var target = position
var curve_point = position
var curve_dist = 300.0
var curve_angle = 60.0
var has_arrived := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary"):
		path.global_position = player.global_position
		path_follow.progress = 0.01
		path.curve.clear_points()
		has_arrived = false
		
		target = get_global_mouse_position()
		var dist = player.global_position.distance_to(target)
		var to_target = (target - player.global_position).normalized()
		var forward = Vector2(
			cos(player.global_rotation - deg_to_rad(90)), 
			sin(player.global_rotation - deg_to_rad(90))
		)
		var angle_deg = rad_to_deg(forward.angle_to(to_target))
		
		path.curve.add_point(to_local(player.global_position))

		if dist < curve_dist or (angle_deg >= -curve_angle and angle_deg <= curve_angle):
			path.curve.add_point(to_local(target))
		else:
			curve_point = Vector2(
				curve_dist * sin(player.global_rotation) + player.global_position.x,
				curve_dist * cos(player.global_rotation) + player.global_position.y
			)
			path.curve.add_point(to_local(target), to_local(curve_point - target))
	if event.is_action_pressed("right1"):
		Global.windows_manager.spawn_window()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("secondary"):
		player.global_position = path_follow.global_position
		var target_rotation = path_follow.global_rotation + deg_to_rad(90)
		player.global_rotation = lerp_angle(player.global_rotation, target_rotation, player.rotation_smoothness * delta)
		if path_follow.progress_ratio + player.move_speed * delta < 1.0:
			path_follow.progress_ratio += player.move_speed * delta
			Global._process_fuel(delta)
		elif not has_arrived:
			has_arrived = true
			print("arrive")
