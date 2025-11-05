extends Node

@onready var main = get_tree().get_first_node_in_group("main")
@onready var players := get_tree().get_nodes_in_group("player")

@export var max_fuel := 100.0
var cur_fuel := 0.0
var fuel_heating_speed := 5.0

@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	add_fuel(max_fuel)

func _init_signals():
	health_component.died.connect(game_over)

func _physics_process(delta: float) -> void:
	_process_fuel(delta)

func _process_fuel(delta: float):
	cur_fuel -= fuel_heating_speed * delta
	if cur_fuel <= 0: 
		cur_fuel = 0.0
		if main: main.is_paused = true

func add_fuel(amount: float) -> void:
	print("Fuel increased by:", amount)
	cur_fuel = clampf(cur_fuel + amount, 0, max_fuel)
	if cur_fuel > 0 and main: main.is_paused = false

func add_health(amount: int) -> void:
	print("Healed by:", amount)
	health_component.cur_hp += amount

func add_shield(amount: int) -> void:
	print("Shield boosted by:", amount)

func enter_station(station: Station):
	print("player has entered ", station.name)

func game_over():
	print("--- Game Over ---")
