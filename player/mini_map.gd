extends CanvasLayer
class_name MiniMap

@onready var background: TextureRect = %Background
@onready var viewport: SubViewportContainer = %SubViewportContainer
@onready var radius = (viewport.get_viewport_rect().size.x / 2) / mini_map_camera.zoom.x / (get_window().size.x / viewport.size.x)
@onready var scan_effect: ColorRect = %ScanEffect

@export var player: Player
var player_marker
var markers := {}

@export var mini_map_camera: Camera2D

@onready var scan_timer: Timer = %ScanTimer
var scan_wait_time := 4.0
var marker_age := {}   # { obj: seconds_since_seen }
var fade_speed := 0.3
@onready var mat: ShaderMaterial = scan_effect.material
var scan_elapsed := 0.0
var scanning := false
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var side_sub_viewport: SubViewport = $"../GameControl/SideScreen/SubViewport"
@onready var radar: Control = $SubViewportContainer/SubViewport/Radar
@onready var control_menu: Control = $SubViewportContainer/SubViewport/Menu

@onready var menu_screens: Array[Control] = [%About, %Control, %Control2, %Start]

func set_menu(menu_id: int):
	radar.hide()
	control_menu.show()
	for screen in menu_screens:
		screen.hide()
	menu_screens[menu_id].show()

func set_game():
	control_menu.hide()
	radar.show()

func _ready() -> void:
	init_player_marker()
	get_minimap_objs()
	scan_timer.timeout.connect(_on_scan_timer_timeout)

func update_camera():
	if not mini_map_camera: return
	mini_map_camera.global_position = player.global_position
	#mini_map_camera.global_rotation = player.global_rotation

func _physics_process(delta: float) -> void:
	if scanning:
		scan_elapsed += delta
		mat.set_shader_parameter("scan_time", scan_elapsed)
	# stop when effect finishes (adjust radius/speed)
	if scan_elapsed >= scan_timer.wait_time: 
		mat.set_shader_parameter("scan_active", false)
		scanning = false
	if not player: return
	if player_marker:
		player_marker.global_position = player.global_position
		player_marker.rotation = player.rotation
	update_camera()
	for obj in markers.keys():
		if is_instance_valid(obj):
			var marker : RadarObjComponent = markers[obj]
			marker_age[obj] += delta
			var new_alpha = clamp(1.0 - marker_age[obj] * fade_speed, 0.0, 1.0)
			marker.modulate.a = new_alpha
			var marker_offset = obj.global_position - player.global_position
			var distance = marker_offset.length()
			if distance > radius:
				var clamped_offset = marker_offset.normalized() * radius
				marker.global_position = player.global_position + clamped_offset
				marker.global_position = marker.global_position
				marker.scale = Vector2(0.65, 0.65)

func _on_scan_timer_timeout() -> void:
	scan_timer.wait_time = scan_wait_time
	scan_timer.start()
	mat.set_shader_parameter("scan_active", true)
	scanning = true
	scan_elapsed = 0.0
	for marker in markers.keys():
		marker_age[marker] = 0.0
	update_markers_position()

func refresh_marker(obj):
	if markers.has(obj):
		marker_age[obj] = 0.0
		markers[obj].modulate.a = 1.0

func init_player_marker():
	if not player: 
		return
	player_marker = player.get_node("RadarObjComponent") as RadarObjComponent
	if player_marker:
		player_marker.show()

func get_minimap_objs():
	var map_objs = get_tree().get_nodes_in_group("radar_objs")
	for obj in map_objs:
		if not obj in markers:
			var marker = obj.get_node("RadarObjComponent") as RadarObjComponent
			if marker:
				marker.show()
				markers[obj] = marker
				marker_age[obj] = 0.0
	_on_scan_timer_timeout()

func update_markers_position():
	for obj in markers.keys():
		if is_instance_valid(obj):
			var marker: RadarObjComponent = markers[obj]
			var marker_offset = obj.global_position - player.global_position
			var distance = marker_offset.length()

			marker.global_rotation = obj.global_rotation

			if distance > radius:
				var clamped_offset = marker_offset.normalized() * radius
				marker.global_position = player.global_position + clamped_offset
				marker.scale = Vector2(0.65, 0.65)
			else:
				marker.global_position = obj.global_position
				marker.scale = Vector2(1, 1)

func remove_marker(marker_obj: Node2D):
	if not marker_obj or not markers.has(marker_obj):
		return
	var window: Wwindow = marker_obj.get_parent()
	markers.erase(marker_obj)
	marker_age.erase(marker_obj)
	window._clear_window()
	marker_obj.call_deferred("queue_free")
