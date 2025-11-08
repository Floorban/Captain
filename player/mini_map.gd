extends CanvasLayer
class_name MiniMap

@onready var background: TextureRect = %Background
@onready var viewport: SubViewportContainer = %SubViewportContainer

@export var player: Player
var player_marker
var markers := {}

@export var mini_map_camera: Camera2D

@onready var scan_timer: Timer = %ScanTimer
var scan_wait_time := 2.0
var marker_age := {}   # { obj: seconds_since_seen }
var fade_speed := 0.3
@onready var mat: ShaderMaterial = viewport.material
var scan_elapsed := 0.0
var scanning := false

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
		var marker : RadarObjComponent = markers[obj]
		marker_age[obj] += delta
		var new_alpha = clamp(1.0 - marker_age[obj] * fade_speed, 0.0, 1.0)
		marker.modulate.a = new_alpha

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
	var radius = (viewport.get_viewport_rect().size.x / 2) / mini_map_camera.zoom.x / (get_window().size.x / viewport.size.x)
	for obj in markers.keys():
		var marker: RadarObjComponent = markers[obj]
		var marker_offset = obj.global_position - player.global_position
		var distance = marker_offset.length()

		marker.global_rotation = obj.global_rotation

		if distance > radius:
			var clamped_offset = marker_offset.normalized() * radius
			marker.global_position = player.global_position + clamped_offset
			marker.scale = Vector2(0.5, 0.5)
		else:
			marker.global_position = obj.global_position
			marker.scale = Vector2(1, 1)
