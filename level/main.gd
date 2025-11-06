extends Node2D
class_name Main

@export var is_paused := false
@export var speed := 5.0
@onready var shop: Shop = %Shop
@onready var fuel_bar: ProgressBar = %FuelBar

func _ready() -> void:
	Global.game_setup()

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	global_position.y += speed * Global.game_speed * delta

func update_fuel_bar(fuel_ratio: float):
	fuel_bar.value = fuel_ratio * 100

func open_shop():
	shop.show()

func close_shop():
	shop.hide()
