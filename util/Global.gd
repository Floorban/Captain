extends Node

enum GAME_STATE {
	PAUSED,
	MOVING,
	STOP
}

@onready var main : Main = get_tree().get_first_node_in_group("main")
var players : Array[Player]

var game_speed := 1.0

@export var max_fuel := 200.0
var cur_fuel := 0.0
var fuel_heating_speed := 5.0

var health_component: HealthComponent

var windows_manager: WindowManager

var game_controller: GameControl

var radar_controller: RadarController

var max_load := 100.0
var cur_load := 0.0

func game_setup():
	players = get_players()
	health_component = get_captain().health_component
	_init_signals()
	add_fuel(max_fuel/2)

func _init_signals():
	if health_component and not health_component.died.is_connected(game_over):
		health_component.died.connect(game_over)

func _process_fuel(delta: float):
	cur_fuel -= fuel_heating_speed * delta
	if main: main.update_fuel_bar(cur_fuel / max_fuel)
	if cur_fuel <= 0: 
		cur_fuel = 0.0
		get_captain().can_move = false

func get_players() -> Array[Player]:
	var nodes = get_tree().get_nodes_in_group("player")
	var pps : Array[Player]
	for n in nodes:
		if n is Player:
			var p = n as Player
			pps.append(p)
	return pps

func get_captain() -> Player:
	for p in players:
		if p.is_captain:
			return p
	return null

func add_fuel(amount: float) -> void:
	cur_fuel = clampf(cur_fuel + amount, 0, max_fuel)
	if main:
		main.update_fuel_bar(cur_fuel / max_fuel)
	if cur_fuel > 0:
		get_captain().can_move = true

func add_health(amount: int) -> void:
	if health_component: health_component.cur_hp += amount

func add_load(amount: float):
	cur_load = clamp(cur_load + amount, 0, max_load)

func add_shield(amount: int) -> void:
	print("Shield boosted by:", amount)

func update_stats():
	game_controller.side_screen.set_stats_screen()

func enter_station(station: Station):
	print("player has entered ", station.name)

func exit_station():
	#could spawn a player if it died
	max_fuel += 100.0
	add_fuel(max_fuel)
	game_setup()
	main.close_shop()
	for p in players:
		p.health_component.cur_hp += p.health_component.max_hp

func game_over():
	print("--- Game Over ---")
	windows_manager.close_all_windows()
	for p in get_players():
		p.is_dead = true
