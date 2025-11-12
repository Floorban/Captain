extends Node2D
class_name Nothing

@export var player : Player 
@onready var attack_component: AttackComponent = $AttackComponent
@onready var radar_obj_component: RadarObjComponent = $RadarObjComponent
@onready var spawn_timer: Timer = $SpawnTimer

@export var base_distance := 2000.0      # how far it starts circling from player
@export var min_distance := 300.0        # how close it gets before attacking
@export var blink_time := 0.2            # how long the blink lasts
@export var max_appearances := 10
@export var attack_distance := 200.0
@export var rest_time := 1.0

var current_appearance := 0
var target_point: Vector2
var level_aggression := 1.0
var can_attack := false
var blink_tween: Tween

func _ready() -> void:
	radar_obj_component.display_name = "Unknow Signal"
	radar_obj_component.display_color = Color.RED
	
	level_aggression = 1.0 + Global.main.cur_lvl_id * 0.0
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_restart_timer()

func _restart_timer() -> void:
	spawn_timer.wait_time = randf_range(1.0 / level_aggression, 2.0 / level_aggression)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	_do_monster_behavior()

func _do_monster_behavior() -> void:
	if not player or can_attack:
		return
	var t := clampf(float(current_appearance) / float(max_appearances), 0.0, 1.0)
	var distance : float = lerp(base_distance, min_distance, t)
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * distance
	var target_pos = player.global_position + offset
	global_position = target_pos
	
	current_appearance += 1
	if current_appearance >= max_appearances:
		attack_player()
	else:
		_restart_timer()

func blink_in() -> void:
	if blink_tween:
		blink_tween.kill()

	show()
	radar_obj_component.icon.visible = true
	radar_obj_component.icon.modulate.a = 0.0
	radar_obj_component.is_detectable = false

	blink_tween = get_tree().create_tween()
	var blink_dur := blink_time * randf_range(0.01, 0.05)
	blink_tween.tween_property(
		radar_obj_component.icon,
		"modulate:a",
		1.0,
		blink_dur
	)

	var flicker_count := randi_range(2, 5)
	for i in range(flicker_count):
		radar_obj_component.is_detectable = not radar_obj_component.is_detectable
		await get_tree().create_timer(randf_range(0.05, 0.15)).timeout

	radar_obj_component.is_detectable = true
	await blink_tween.finished

func attack_player() -> void:
	if can_attack:
		return
	can_attack = true
	player.hitbox_component.apply_damage(attack_component)
	await get_tree().create_timer(rest_time).timeout
	can_attack = false
	current_appearance = 0
	attack_component.attack_damage += 1
	_restart_timer()
