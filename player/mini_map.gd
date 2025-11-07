extends CanvasLayer
class_name MiniMap

@onready var viewport: SubViewportContainer = %SubViewportContainer

@export var player: Player
var player_marker
var markers := {}

@export var mini_map_camera: Camera2D
var scan_radius : float
@export var zoom := 1.0

func _ready() -> void:
	scan_radius = viewport.size.x
	init_player_marker()
	get_minimap_objs()
	#background.size = Vector2(scan_radius, scan_radius)
	#background.set_anchors_preset(Control.PRESET_CENTER)

func update_camera():
	if not mini_map_camera: return
	#mini_map_camera.zoom = Vector2.ONE * (1.0 / scan_radius / 100.0)
	mini_map_camera.global_position = player.global_position

func _physics_process(_delta: float) -> void:
	if not player: return
	if player_marker: 
		player_marker.global_position = player.global_position
		player_marker.rotation = player.rotation
	update_camera()
	for obj in markers:
		var obj_pos = obj.global_transform.origin
		var marker_offset : Vector2 = obj.global_position - player.global_position
		var distance = marker_offset.length()
		#obj_pos.x = clamp(obj_pos.x, 0, get_window().size.x)
		#obj_pos.y = clamp(obj_pos.y, 0, get_window().size.y)
		if distance > scan_radius / 2:
			print(distance)
			var clamped_offset = marker_offset.normalized() * (scan_radius / 2)
			markers[obj].position = player.global_position + clamped_offset
		else:
			markers[obj].position = obj_pos

func init_player_marker():
	if not player: 
		return
	player_marker = player.get_node("RadarObjComponent")
	if player_marker:
		player_marker.show()

func get_minimap_objs():
	var map_objs = get_tree().get_nodes_in_group("radar_objs")
	for obj in map_objs:
		var marker = obj.get_node("RadarObjComponent")
		if marker:
			marker.show()
			markers[obj] = marker
