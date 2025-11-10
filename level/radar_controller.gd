extends Camera2D
class_name RadarController

@onready var player: Player = Global.get_captain()
@onready var path: Path2D = $Path2D
@onready var path_follow = $Path2D/PathFollow2D
@onready var mini_map: MiniMap = %MiniMap
@onready var select_marker: SelectMarker = %SelectMarker

var click_pos

var target
var dist : float
var curve_point = position
var curve_dist = 300.0
var curve_angle = 60.0
var has_arrived := false

var send_ship_delay := 500
@onready var monitor: Monitor = $"../Monitor"
var can_control := false

func _ready() -> void:
	Global.radar_controller = self

func _input(event: InputEvent) -> void:
	_set_destination(event)

func _physics_process(delta: float) -> void:
	_go_to_destination(delta)

func _set_destination(event):
	if event.is_action_pressed("primary") and can_control:
		if event.global_position.x < 275 or event.global_position.x > 630 or event.global_position.y < 125 or event.global_position.y > 470:
			return
		click_pos = event.global_position
		can_send = true
		select_marker.global_position = click_pos + Vector2(-10,-10)
		select_marker.no_result(("x: " + str(int(click_pos.x))),("y: " + str(int(click_pos.y))))

		target = get_global_mouse_position()
		dist = player.global_position.distance_to(target)
		
		for obj in mini_map.markers:
			if is_instance_valid(obj):
				var marker : RadarObjComponent = mini_map.markers[obj]
				var distance = obj.global_position.distance_to(target)
				if distance < 100 and marker.modulate.a > 0.1:
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
	if Input.is_action_pressed("secondary") and target != null and can_control:
		monitor.trauma = 0.2
		monitor.target_speed = 8.0
		select_marker.hide_labels()
		can_send = false
		player.global_position = path_follow.global_position
		var target_rotation = path_follow.global_rotation + deg_to_rad(90)
		player.global_rotation = lerp_angle(player.global_rotation, target_rotation, player.rotation_smoothness * delta)
		if path.curve.point_count > 0 and path_follow.progress_ratio + player.move_speed * delta < 1.0:
			path_follow.progress_ratio += player.move_speed * delta
			Global._process_fuel(delta)
		elif not has_arrived:
			has_arrived = true
			monitor.trauma = 0.3
			monitor.target_speed = 0.0
			Input.action_release("secondary")
			print("arrive")
	if Input.is_action_just_released("secondary") and not has_arrived and can_control:
		monitor.trauma = 0.3
		monitor.target_speed = 0.0

func send_ship(btn: Button, loading_bar: ProgressBar, axis_label: Label):
	if target != null and can_send:
		var distance := player.global_position.distance_to(target)
		var delay := distance / send_ship_delay
		wait_and_spawn(delay, target, btn, loading_bar, axis_label)

var ship_amonut := 3

var send_ship_tween : Tween
var is_sending := false
var can_send := false

func wait_and_spawn(delay: float, pos: Vector2, btn: Button, loading_bar: ProgressBar, axis_label: Label) -> void:
	if is_sending:
		if send_ship_tween:
			send_ship_tween.kill()
		loading_bar.value = 0.0
		is_sending = false
		btn.text = "SEND A SHIP"
		axis_label.text = "SELECT A \n DESTINATION"
		path.curve.clear_points()
		select_marker.hide()
		can_send = false
		return
	if ship_amonut <= 0:
		btn.text = "NOT ENOUGH"
		axis_label.text = "RUN OUT OF \n SHIPS"
		return
	is_sending = true
	axis_label.text = "SENDING TO\n" + ("( " + str(int(click_pos.x))) + (", " + str(int(click_pos.y)) + " )")
	btn.text = "STOP"
	var end_value := loading_bar.max_value
	if send_ship_tween:
		send_ship_tween.kill()
	send_ship_tween = get_tree().create_tween()
	send_ship_tween.tween_property(loading_bar, "value", end_value, delay)
	send_ship_tween.finished.connect(func():
		Global.windows_manager.spawn_window(pos)
		loading_bar.value = 0.0
		is_sending = false
		btn.text = "SEND A SHIP"
		axis_label.text = "SELECT A \n DESTINATION"
		path.curve.clear_points()
		select_marker.hide()
		can_send = false
		ship_amonut -= 1
	)

func remove_ship_radar_obj(ship: Node2D):
	if not ship:
		return
	ship_amonut += 1
	mini_map.remove_marker(ship)
