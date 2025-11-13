extends Area2D
class_name DetectionArea

@onready var detection_radius: Sprite2D = $DetectionRadius
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var col : CircleShape2D = collision_shape.shape

var detected_obstacles : Array[Obstacle] = []
var detected_stations : Array[Station] = []

@export var is_captain := false

func grow_detection_radius(_scale: float):
	detection_radius.scale *= _scale
	col.radius *= _scale

func _ready() -> void:
	body_entered.connect(_on_detection_area_body_entered)
	body_exited.connect(_on_detection_area_body_exited)

var seen_enemy := false

func _on_detection_area_body_entered(body: Node2D) -> void:
	var marker : RadarObjComponent = body.get_node("RadarObjComponent")
	if not marker: return
	marker.is_detectable = true
	if body is Nothing:
		seen_enemy = true
		#Global.radar_controller.monitor.start_danger_blink()
		Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ALERT)
		if not is_captain and global_position.direction_to(body.global_position).length() <= 20.0:
			var n : Nothing = body
			if n.has_shown and not n.has_interrupted:
				n.interrupt_behaviour()
	if body is Obstacle:
		var o : Obstacle = body
		detected_obstacles.append(o)
		#Global.radar_controller.monitor.start_danger_blink()
	if body is Station:
		var s : Station = body
		detected_stations.append(s)
		Audio.create_2d_audio_at_location(SoundEffect.SOUND_EFFECT_TYPE.UI_CONFIRM, s.global_position)
		Global.game_controller.side_screen.set_control_screen(s)

func _on_detection_area_body_exited(body: Node2D) -> void:
	var marker : RadarObjComponent = body.get_node("RadarObjComponent")
	if not marker: return
	if body is Nothing and seen_enemy:
		seen_enemy = false
		Global.radar_controller.monitor.stop_danger_blink()
		Global.game_controller.side_screen.set_control_screen(null)
	if body is Obstacle and detected_obstacles.has(body):
		marker.is_detectable = false
		detected_obstacles.erase(body)
		if detected_obstacles.size() <= 0 and not seen_enemy:
			Global.radar_controller.monitor.stop_danger_blink()
	if body is Station and detected_stations.has(body):
		#marker.is_detectable = false
		detected_stations.erase(body)
		if detected_stations.size() <= 0:
			Global.game_controller.side_screen.set_control_screen(null)
