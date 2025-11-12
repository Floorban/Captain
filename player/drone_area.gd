extends Area2D
class_name DroneArea

@onready var detection_radius: Sprite2D = $DetectionRadius
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var col : CircleShape2D = collision_shape.shape

@onready var my_player : Player = get_parent().get_parent()
var detected_drones : Array[Player] = []

func grow_detection_radius(_scale: float):
	detection_radius.scale *= _scale
	col.radius *= _scale

func _ready() -> void:
	body_entered.connect(_on_detection_area_body_entered)
	body_exited.connect(_on_detection_area_body_exited)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body == my_player and body is Player:
		var marker : RadarObjComponent = body.get_node("RadarObjComponent")
		marker.is_detectable = true
		var p : Player = body
		p.can_move = true
		detected_drones.append(p)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player and detected_drones.has(body):
		var p : Player = body
		p.can_move = false
		var marker : RadarObjComponent = body.get_node("RadarObjComponent")
		marker.is_detectable = false
		detected_drones.erase(body)
		if detected_drones.size() <= 0:
			Global.radar_controller.monitor.stop_danger_blink()
			# lose signal prompt
			
