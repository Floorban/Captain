extends Node2D
class_name Main

@export var fuel_bar: ProgressBar
@onready var mini_map: MiniMap = %MiniMap

@export var lvls : Array[PackedScene] = []  # store scenes, not nodes
var cur_lvl: Node2D = null
var cur_lvl_id := 0

func _ready() -> void:
	Global.game_setup()
	_load_level(cur_lvl_id)

func update_fuel_bar(fuel_ratio: float):
	fuel_bar.value = fuel_ratio * 100

func _load_level(id: int):
	if cur_lvl:
		cur_lvl.queue_free()
	if id < 0 or id >= lvls.size():
		print("no more levels.")
		return
	var lvl_scene := lvls[id]
	cur_lvl = lvl_scene.instantiate()
	cur_lvl.global_position = Global.get_captain().global_position
	add_child(cur_lvl)
	print("Loaded level", id)
	if Global.game_controller:
		Global.game_controller.mini_map.get_minimap_objs()

func go_up():
	cur_lvl_id += 1
	_load_level(cur_lvl_id)
