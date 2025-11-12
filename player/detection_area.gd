extends Area2D
class_name DetectionArea

var radius = 250.0
@onready var detection_radius: Sprite2D = $DetectionRadius
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func grow_detection_radius(_scale: float):
	apply_scale(Vector2(_scale, _scale))
	radius *= _scale
	print(radius)

func _ready() -> void:
	body_entered.connect(_on_detection_area_body_entered)
	body_exited.connect(_on_detection_area_body_exited)

var detected_obstacles : Array[Obstacle] = []
var detected_stations : Array[Station] = []

func _on_detection_area_body_entered(body: Node2D) -> void:
	var marker : RadarObjComponent = body.get_node("RadarObjComponent")
	if not marker: return
	marker.is_detectable = true
	if body is Obstacle:
		var o : Obstacle = body
		detected_obstacles.append(o)
		Global.radar_controller.monitor.start_danger_blink()
	if body is Station:
		var s : Station = body
		detected_stations.append(s)
		Global.game_controller.side_screen.set_control_screen(s)

func _on_detection_area_body_exited(body: Node2D) -> void:
	var marker : RadarObjComponent = body.get_node("RadarObjComponent")
	if not marker: return
	if body is Obstacle and detected_obstacles.has(body):
		marker.is_detectable = false
		detected_obstacles.erase(body)
		if detected_obstacles.size() <= 0:
			Global.radar_controller.monitor.stop_danger_blink()
	if body is Station and detected_stations.has(body):
		marker.is_detectable = false
		detected_stations.erase(body)
		if detected_stations.size() <= 0:
			Global.game_controller.side_screen.set_control_screen(null)
