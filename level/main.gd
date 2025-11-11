extends Node2D
class_name Main

@export var fuel_bar: ProgressBar
@onready var mini_map: MiniMap = %MiniMap

func _ready() -> void:
	Global.game_setup()

func update_fuel_bar(fuel_ratio: float):
	fuel_bar.value = fuel_ratio * 100

func refresh_level(lvl_id: int):
	pass
