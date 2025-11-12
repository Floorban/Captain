extends Node2D
class_name Main

@export var fuel_bar: ProgressBar
@onready var mini_map: MiniMap = %MiniMap

@export var lvls : Array[PackedScene] = []  # store scenes, not nodes
var current_lvl: Node2D = null
var current_lvl_id := 0

func _ready() -> void:
	Global.game_setup()
	_load_level(current_lvl_id)

func update_fuel_bar(fuel_ratio: float):
	fuel_bar.value = fuel_ratio * 100

func _load_level(id: int):
	if current_lvl:
		current_lvl.queue_free()
	if id < 0 or id >= lvls.size():
		print("no more levels.")
		return
	var lvl_scene := lvls[id]
	current_lvl = lvl_scene.instantiate()
	add_child(current_lvl)
	print("Loaded level", id)

func go_up():
	current_lvl_id += 1
	_load_level(current_lvl_id)
