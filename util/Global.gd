extends Node

var main : Main
var windows_manager: WindowManager
var game_controller: GameControl
var radar_controller: RadarController
var nothing: Nothing

var players : Array[Player]
var cur_station: Station

var is_dead := false
var health_component: HealthComponent

@export var max_fuel := 200.0
var cur_fuel := 0.0
var fuel_heating_speed := 2.5

var max_load := 100.0
var cur_load := 0.0

var added_player_speed := 0.0
var added_player_hp := 0
var added_pickup_time := 0.0
var drone_vision_scale := Vector2.ONE
@export var salvage_res : ItemData
@export var cell_res : ItemData

var upgrade_effects = {
	"max_hull": func() -> void:
		health_component.max_hp += 1
		health_component.health_bar.update_hp_bar(health_component.cur_hp)
		update_stats(),
	"max_fuel": func() -> void:
		max_fuel += 25.0
		update_stats(),
	"fuel_efficiency": func(): fuel_heating_speed -= 1.0,
	"max_speed": func(): get_captain().move_speed += 25.0,
	"cargo_capacity": func() -> void:
		max_load += 50.0
		update_stats(),
	"scan_speed": func(): radar_controller.mini_map.scan_wait_time -= 0.5,
	"deploy_range": func(): get_captain().detection_area.grow_detection_radius(1.5),
	"drone_signal_range": func(): get_captain().drone_area.grow_detection_radius(1.4),
	"drone_vision": func(): drone_vision_scale *= 1.2,
	"drone_speed": func(): added_player_speed += 20.0,
	"drone_capacity": func() -> void:
		salvage_res.max_stack += 2
		cell_res.max_stack += 2,
	"fuel_cell_efficiency": func(): cell_res.value *= 2.0,
	"drone_max_hp": func(): added_player_hp += 1,
	"radar_fade": func(): radar_controller.mini_map.fade_speed -= 0.15,
	"pickup_time": func(): added_pickup_time += 0.5
}

func game_setup():
	players = get_players()
	health_component = get_captain().health_component
	_init_signals()
	health_component.cur_hp = health_component.max_hp
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

func add_health(amount: int) -> bool:
	if not health_component or health_component.cur_hp == health_component.max_hp: 
		return false
	health_component.cur_hp += amount
	update_stats()
	return true

func add_load(amount: float):
	cur_load = clamp(cur_load + amount, 0, max_load)

func add_shield(amount: int) -> void:
	print("Shield boosted by:", amount)

func try_consume_fuel(amount: float) -> bool:
	if cur_fuel <= 0 or cur_fuel - max_fuel * amount < 0: 
		return false
	cur_fuel = clamp(cur_fuel - max_fuel * amount, 0, max_fuel)
	return true

func try_consume_load(amount: float) -> bool:
	if cur_load <= 0 or cur_load - amount < 0: 
		return false
	else:
		cur_load = clamp(cur_load - amount, 0, max_load)
		return true

func update_stats():
	if main: main.update_fuel_bar(cur_fuel / max_fuel)
	Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_REFRESH)
	game_controller.side_screen.set_stats_screen()

func enter_station(station: Station):
	windows_manager.set_windows_visibility(false)
	print("player has entered ", station.name)
	main.hide()
	radar_controller.mini_map.set_upgrades(true)
	radar_controller.can_control = false
	cur_station = station
	game_controller.side_screen.set_station_screen()
	get_tree().paused = true
	Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ENTER_STATION)

func exit_station():
	get_tree().paused = false
	windows_manager.set_windows_visibility(true)
	main.show()
	radar_controller.can_control = true
	radar_controller.target = null
	radar_controller.mini_map.set_upgrades(false)
	cur_station = null
	game_controller.side_screen.disable_station_screen()

func ascend():
	Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ARRIVE_NEW_LEVEL)
	cur_fuel = 0.0
	main.go_up()
	update_stats()
	windows_manager.close_all_windows()

func game_over():
	Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ALERT)
	print("--- Game Over ---")
	is_dead = true
	radar_controller.out_ships.clear()
	#radar_controller.path.hide()
	game_controller.retro_effect_rect.show()
	radar_controller.monitor.trauma = 1.5
	#main.hide()
	main.cur_lvl.queue_free()
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
	Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.DEAD)
	windows_manager.close_all_windows()
	for p in get_players():
		p.is_dead = true
	is_dead = false
	await get_tree().create_timer(3.0).timeout
	windows_manager.main_sub_window.queue_free()
	get_tree().call_deferred("quit")
	get_captain().show()
	game_controller.mini_map.death_menu.hide()
	game_controller.retro_effect_rect.hide()
	radar_controller.try_add_drone()
	radar_controller.try_add_drone()
	radar_controller.try_add_drone()
	game_controller.set_game_menu_content(0)

func game_win():
	game_controller.win.show()
	await get_tree().create_timer(1.5).timeout
	game_over()


var label_effect_version := {}  # Label -> int

func play_label_effect(label: Label, full_text: String) -> void:
	label_effect_version[label] = label_effect_version.get(label, 0) + 1
	var my_version = label_effect_version[label]
	label.text = ""
	label.show()
	_blink_label_versioned(label, 6, 0.05, 0.15, my_version)
	_type_glitch_versioned(label, full_text, 0.02, 0.5, my_version)

func _blink_label_versioned(label: Label, blinks: int, min_delay: float, max_delay: float, version: int) -> void:
	if Global.is_dead: return
	for i in range(blinks):
		if label_effect_version[label] != version:
			return
		label.visible = not label.visible
		await get_tree().create_timer(randf_range(min_delay, max_delay)).timeout
	label.visible = true

func _type_glitch_versioned(label: Label, text: String, char_delay: float, glitch_chance: float, version: int) -> void:
	if Global.is_dead: return
	var output := ""
	var chars = text.split("")
	for c in chars:
		if label_effect_version[label] != version:
			return
		if randf() < glitch_chance:
			label.text = output + _random_glitch_char()
			await get_tree().create_timer(char_delay * 0.5).timeout
		output += c
		label.text = output
		await get_tree().create_timer(char_delay).timeout

func _random_glitch_char() -> String:
	var pool = ["#", "%", "&", "*", "@", "?", "/", "\\", "!", "~", "±", "§"]
	return pool[randi() % pool.size()]
