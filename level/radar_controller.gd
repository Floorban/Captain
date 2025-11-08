extends Camera2D
class_name RadarController

@onready var player: Player = Global.get_captain()
@onready var path: Path2D = $Path2D
@onready var path_follow = $Path2D/PathFollow2D
@onready var mini_map: MiniMap = %MiniMap
@onready var select_marker: SelectMarker = %SelectMarker

var target
var dist : float
var curve_point = position
var curve_dist = 300.0
var curve_angle = 60.0
var has_arrived := false

var send_ship_delay := 500
@onready var monitor: Monitor = $"../Monitor"

func _input(event: InputEvent) -> void:
	_set_destination(event)
	send_ship(event)

func _physics_process(delta: float) -> void:
	_go_to_destination(delta)

func _set_destination(event):
	if event.is_action_pressed("primary"):
		var click_pos = event.global_position
		print(click_pos)
		if click_pos.x < 275 or click_pos.x > 630 or click_pos.y < 125 or click_pos.y > 470:
			return
		select_marker.global_position = click_pos
		select_marker.no_result()

		target = get_global_mouse_position()
		dist = player.global_position.distance_to(target)
		
		for obj in mini_map.markers:
			var distance = obj.global_position.distance_to(target)
			if distance < 100:
				select_marker.set_label_text(obj.name, ("x: " + str(int(click_pos.x))),("y: " + str(int(click_pos.y))))
				
		path.global_position = player.global_position
		path_follow.progress = 0.01
		path.curve.clear_points()
		has_arrived = false
		
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

func _go_to_destination(delta):
	if Input.is_action_pressed("secondary") and target != null:
		monitor.trauma = 0.2
		monitor.target_speed = 8.0
		select_marker.hide_labels()
		player.global_position = path_follow.global_position
		var target_rotation = path_follow.global_rotation + deg_to_rad(90)
		player.global_rotation = lerp_angle(player.global_rotation, target_rotation, player.rotation_smoothness * delta)
		if path_follow.progress_ratio + player.move_speed * delta < 1.0:
			path_follow.progress_ratio += player.move_speed * delta
			Global._process_fuel(delta)
		elif not has_arrived:
			has_arrived = true
			monitor.target_speed = 0.0
			print("arrive")
	elif Input.is_action_just_released("secondary"):
		monitor.trauma = 0.3
		monitor.target_speed = 0.0

func send_ship(event):
	if event.is_action_pressed("scan") and target != null:
		var distance := player.global_position.distance_to(target)
		var delay := distance / send_ship_delay
		wait_and_spawn(delay, target)

func wait_and_spawn(delay: float, pos: Vector2) -> void:
	Global.windows_manager.spawn_window(pos, delay)
