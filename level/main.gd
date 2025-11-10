extends Node2D
class_name Main

@export var is_paused := false
@onready var shop: Shop = %Shop
@export var fuel_bar: ProgressBar
@onready var mini_map: MiniMap = %MiniMap

func _ready() -> void:
	Global.game_setup()

func update_fuel_bar(fuel_ratio: float):
	fuel_bar.value = fuel_ratio * 100

func open_shop():
	shop.show()

func close_shop():
	shop.hide()
