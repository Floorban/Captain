extends Node

enum GAME_STATE {
	PAUSED,
	MOVING,
	STOP
}

@onready var main : Main = get_tree().get_first_node_in_group("main")
var players : Array[Player]

var is_dead := false

@export var max_fuel := 200.0
var cur_fuel := 0.0
var fuel_heating_speed := 5.0

var health_component: HealthComponent

var windows_manager: WindowManager

var game_controller: GameControl

var radar_controller: RadarController

var nothing: Nothing

var max_load := 100.0
var cur_load := 0.0

var cur_station: Station

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
	cur_station = station
	game_controller.side_screen.set_station_screen()

func exit_station():
	cur_station = null
	game_controller.side_screen.disable_station_screen()

func ascend():
	cur_fuel = 0.0
	main.go_up()

func game_over():
	print("--- Game Over ---")
	is_dead = true
	radar_controller.path.hide()
	game_controller.retro_effect_rect.show()
	radar_controller.monitor.trauma = 1.5
	#main.hide()
	nothing.queue_free()
	get_captain().hide()
	var ps = get_tree().get_nodes_in_group("radar_objs")
	for p in ps:
		p.hide()
	game_controller.select_marker.hide()
	game_controller.side_screen.set_control_screen(null, false, true)
	game_controller.mini_map.label_death.text = "Connection Failed"
	game_controller.mini_map.death_menu.show()
	await get_tree().create_timer(3.5).timeout
	windows_manager.close_all_windows()
	for p in get_players():
		p.is_dead = true
