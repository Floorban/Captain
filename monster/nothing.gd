extends Node2D
class_name Nothing

var player : Player 
@onready var attack_component: AttackComponent = $AttackComponent
@onready var radar_obj_component: RadarObjComponent = $RadarObjComponent
@onready var spawn_timer: Timer = $SpawnTimer

@export var base_distance := 2000.0
@export var min_distance := 100.0
@export var min_appearances := 10
@export var attack_distance := 200.0
@export var rest_time := 60.0
@export var invisible_chance := 0.0
@export var min_spawn_time := 5.0
@export var max_spawn_time := 10.0

var current_appearance := 0
var target_point: Vector2

func _ready() -> void:
	radar_obj_component.display_name = "Unknow Signal"
	radar_obj_component.display_color = Color.RED

func _restart_timer() -> void:
	var wait_time := randf_range(min_spawn_time, max_spawn_time)
	if player:
		var dist := global_position.distance_to(player.global_position)
		var distance_factor : float = clamp(dist / base_distance, 0.1, 1.0)
		wait_time *= lerp(0.5, 1.0, distance_factor)
	
	spawn_timer.wait_time = wait_time
	spawn_timer.start()
	print("Next spawn in:", wait_time)

func _on_spawn_timer_timeout() -> void:
	_do_monster_behavior()

func _do_monster_behavior() -> void:
	if not player: return
	current_appearance += 1
	radar_obj_component.is_detectable = randf() > invisible_chance
	var t := clampf(float(current_appearance) / float(min_appearances), 0.0, 1.0)
	var distance : float = lerp(base_distance, min_distance, t)
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * distance
	var target_pos = player.global_position + offset
	global_position = target_pos
	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_distance and current_appearance >= min_appearances:
		attack_player()
	else:
		_restart_timer()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scan"):
		attack_player()

func attack_player() -> void:
	if not player: return
	radar_obj_component.is_detectable = true
	global_position = player.global_position
	#await get_tree().create_timer(1.0).timeout
	spawn_timer.paused = true
	player.hitbox_component.apply_damage(attack_component)
	await get_tree().create_timer(1.0).timeout
	reset_behaviour()

func reset_behaviour():
	if not player: return
	spawn_timer.paused = true
	radar_obj_component.is_detectable = false
	
	var offset := Vector2.RIGHT.rotated(randf() * TAU) * base_distance
	global_position = player.global_position + offset
	
	current_appearance = 0
	
	await get_tree().create_timer(rest_time).timeout
	spawn_timer.paused = false
	if not spawn_timer.is_connected("timeout", _on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_restart_timer()

func interrupt_behaviour() -> void:
	if spawn_timer.is_stopped():
		return
	print("nothing being interrupted")
	spawn_timer.paused = true
	await get_tree().create_timer((min_spawn_time+max_spawn_time)/2).timeout
	spawn_timer.paused = false
	reset_behaviour()
