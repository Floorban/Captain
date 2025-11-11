@tool
extends Node2D
class_name Spawner

@export var is_paused := true
@export var speed := 2.0
@export var spawn_test := false:
	set = _spawn_test

@export var spawn_size_width: float = 1000.0
@export var spawn_size_height: float = 5000.0

var objs : Array[Node2D] = []

func _spawn_test(_v: bool):
	spawn_test = false
	get_children_objs()
	randomize_obj_pos()

#func _ready() -> void:
	#is_paused = false
	#get_children_objs()
	#randomize_obj_pos()

func _physics_process(delta: float) -> void:
	move(delta)

func get_children_objs():
	objs.clear()
	for o in get_children():
		objs.append(o)

func randomize_obj_pos():
	if objs.size() <= 0: 
		return
	
	for o in objs:
		var rand_x = randf_range(-spawn_size_width / 2, spawn_size_width / 2)
		var rand_y = randf_range(-spawn_size_height / 2, spawn_size_height / 2)
		o.global_position = global_position + Vector2(rand_x, rand_y)

func move(delta: float) -> void:
	if is_paused:
		return
	
	global_position.y += speed * Global.game_speed * delta
