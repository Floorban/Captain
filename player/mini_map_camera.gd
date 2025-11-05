extends Camera2D
class_name MiniMapCam

@export var scan_radius := 50.0
var player: Player
@export var pois: Array[Station] = []

func _ready() -> void:
	#pois = GameManager.main.cities
	#player = GameManager.get_player()
	zoom = Vector2(scan_radius, scan_radius)

func _process(_delta: float) -> void:
	position = Vector2(player.position.x, player.position.y)
	var player_pos = player.global_transform.origin
	for poi in pois:
		var poi_pos = poi.global_transform.origin
		var offset = Vector3(poi_pos.x, 0, poi_pos.z) - Vector3(player_pos.x, 0, player_pos.z)
		var distance = offset.length()
		if distance > scan_radius / 2:
			# Clamp to minimap edge
			var clamped_offset = offset.normalized() * (scan_radius / 2 - 3.0)
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
