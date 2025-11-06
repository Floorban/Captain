extends Camera2D
class_name MiniMapCam

@export var scan_radius := 50.0
@export var player: Player
@export var pois: Array[Station] = []

func _ready() -> void:
	zoom = Vector2(scan_radius, scan_radius)

func _physics_process(_delta: float) -> void:
	if player: position = Vector2(player.position.x, player.position.y)
	var player_pos = player.global_transform.origin if player else Vector2.ZERO
	for poi in pois:
		var poi_pos = poi.global_transform.origin
		var _offset = Vector2(poi_pos.x, poi_pos.y) - Vector2(player_pos.x, player_pos.y)
		var distance = _offset.length()
		if distance > scan_radius / 2:
			# Clamp to minimap edge
			var clamped_offset = _offset.normalized() * (scan_radius / 2 - 3.0)
			poi.icon.global_transform.origin = Vector2(
				player_pos.x + clamped_offset.x,
				player_pos.y + clamped_offset.y)
			poi.icon.scale = Vector2(10, 10)
		else:
			poi.icon.global_transform.origin = Vector2(
				poi_pos.x,
				poi_pos.y)
			poi.icon.scale = Vector2(15, 15)
		
		var height_diff = abs(poi_pos.y - player_pos.y)
		if height_diff <= 15.0:
			poi.icon.modulate.a = 1.0
		elif height_diff <= 50.0:
			poi.icon.modulate.a = 0.7
		else:
			poi.icon.modulate.a = 0.3
