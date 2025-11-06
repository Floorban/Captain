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

@export var window_scene : PackedScene
@export var spawn_size_width: float = 1000.0
@export var spawn_size_height: float = 1000.0

func random_pos(spawn_size: float) -> float:
	return randf_range(-spawn_size / 2, spawn_size / 2)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary"):
		var w = window_scene.instantiate()
		if w is Wwindow:
			w.init_window(random_pos(spawn_size_width), random_pos(spawn_size_height))
		add_child(w)
