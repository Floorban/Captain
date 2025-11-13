extends SubViewportContainer
class_name SideScreen

@onready var main_menu: VBoxContainer = $SubViewport/Background/MainMenu
@onready var button_1: Button = %Button1
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4

@onready var game_menu: MarginContainer = $SubViewport/Background/GameMenu
@onready var b_1: Button = %B1
@onready var b_2: Button = %B2
@onready var b_3: Button = %B3

@onready var hud_control: Control = $SubViewport/Background/GameMenu/Panel/HUD_Control
@onready var label_control: Label = $SubViewport/Background/GameMenu/Panel/HUD_Control/LabelControl
@onready var label_detection: Label = $SubViewport/Background/GameMenu/Panel/HUD_Control/LabelDetection

@onready var send_ship_bar: ProgressBar = %SendShipBar
@onready var label_send: Label = %LabelSend

@onready var hud_send: Control = $SubViewport/Background/GameMenu/Panel/HUD_Send

@onready var hud_stats: Control = $SubViewport/Background/GameMenu/Panel/HUD_Stats
@onready var label_hp: Label = %LabelHP
@onready var label_fuel: Label = %LabelFUEL
@onready var label_load: Label = %LabelLOAD
@onready var load_bar: ProgressBar = %LoadBar

@onready var hud_goup: Control = $SubViewport/Background/GameMenu/Panel/HUD_GOUP
@onready var label_goup: Label = %LabelGOUP
@onready var goingup_bar: ProgressBar = %GoingupBar

func bind_button_to_menu(id:int):
	Global.game_controller.set_game_menu_content(id)

func set_main_menu():
	can_goup = false
	going_up = false
	main_menu.show()
	game_menu.hide()
	button_1.grab_focus()
	if not button_1.is_connected("pressed", bind_button_to_menu.bind(0)):
		button_1.pressed.connect(bind_button_to_menu.bind(0))
	if not button_2.is_connected("pressed", bind_button_to_menu.bind(1)):
		button_2.pressed.connect(bind_button_to_menu.bind(1))
	if not button_3.is_connected("pressed", bind_button_to_menu.bind(2)):
		button_3.pressed.connect(bind_button_to_menu.bind(2))
	if not button_4.is_connected("pressed", bind_button_to_menu.bind(3)):
		button_4.pressed.connect(bind_button_to_menu.bind(3))
	button_1.text = "ABOUT"
	button_2.text = "CONTROL1"
	button_3.text = "CONTROL2"
	button_4.text = "START"

func set_game_menu():
	can_goup = false
	going_up = false
	main_menu.hide()
	game_menu.show()
	b_1.grab_focus()
	set_control_screen(null, true)
	if not b_1.is_connected("pressed", set_send_screen):
		b_1.pressed.connect(set_send_screen)
	if not b_2.is_connected("pressed", set_stats_screen):
		b_2.pressed.connect(set_stats_screen)
	if not b_3.is_connected("pressed", set_ascend_screen):
		b_3.pressed.connect(set_ascend_screen)
	b_1.text = "SEND A SHIP"
	b_2.text = "STATS"
	b_3.text = "GO UP"

func set_control_screen(found_target: Station, first_time := false, is_dead := false, see_nothing := false):
	can_goup = false
	going_up = false
	hud_control.show()
	hud_send.hide()
	hud_stats.hide()
	hud_goup.hide()
	label_control.hide()
	#label_detection.hide()
	if is_dead:
		#%SelectMarker.hide()
		label_control.modulate = Color.RED
		label_control.text = "No Response"
	elif see_nothing:
		var msg = "There is Nothing..."
		label_control.modulate = Color.RED
		play_label_effect(label_control, msg)
	elif found_target:
		var pos := found_target.axis
		var msg = "Station Detected\n(%d, %d)\n%s" % [
			int(pos.x),
			int(pos.y),
		    "Go Get Upgrades"
		]
		label_control.modulate = Color.GREEN
		play_label_effect(label_control, msg)
	else:
		var messages = []
		if first_time:
			messages = [
				"Left Click: Select
				Right Click: Move
				Space: Press Btn"
			]
		else:
			messages = [
				"Left Click: Select
				Right Click: Move
				Space: Press Btn",
				
				"Get Upgrades 
				at Stations",
				
				"You Have a Max.
				of 3 Drones",
				
			    "Monitor Your 
				HP & FUEL",
				
				"Return Drones to 
				Unload & Reuse"
			]
		var msg = messages.pick_random()
		label_control.modulate = Color.WHITE
		play_label_effect(label_control, msg)

func set_send_screen():
	can_goup = false
	going_up = false
	hud_control.hide()
	hud_send.show()
	hud_stats.hide()
	hud_goup.hide()
	play_label_effect(label_send, "Target Required")
	#label_send.text = "Target Required"
	Global.radar_controller.send_ship(b_1, send_ship_bar, label_send)

func set_stats_screen():
	can_goup = false
	going_up = false
	#b_2.grab_focus()
	hud_control.hide()
	hud_send.hide()
	hud_stats.show()
	hud_goup.hide()
	var hp_percent = (float(Global.health_component.cur_hp) / Global.health_component.max_hp) * 100
	var fuel_percent = (Global.cur_fuel / Global.max_fuel) * 100
	var load_value = Global.cur_load / Global.max_load
	var load_percent = load_value * 100

	var msg_hp = "HULL:  " + str(int(hp_percent)) + " %"
	var msg_fuel = "Fuel:  " + str(int(fuel_percent)) + " %"
	var msg_load = "LOAD:  " + str(int(load_percent)) + " KG"
	play_label_effect(label_hp, msg_hp)
	play_label_effect(label_fuel, msg_fuel)
	play_label_effect(label_load, msg_load)
	animate_load_bar(load_bar, load_value)

func set_station_screen():
	set_stats_screen()
	b_3.grab_focus()
	b_1.pressed.disconnect(set_send_screen) 
	b_2.pressed.disconnect(set_stats_screen)
	b_3.pressed.disconnect(set_ascend_screen)
	b_1.pressed.connect(buy_drone) 
	b_2.pressed.connect(repair_hull)
	b_3.pressed.connect(exit_station)
	b_1.text = "BUY DRONE"
	b_2.text = "REPAIR"
	b_3.text = "EXIT"

func disable_station_screen():
	b_1.pressed.disconnect(buy_drone) 
	b_2.pressed.disconnect(repair_hull)
	b_3.pressed.disconnect(exit_station)
	b_1.pressed.connect(set_send_screen) 
	b_2.pressed.connect(set_stats_screen)
	b_3.pressed.connect(set_ascend_screen)
	b_1.text = "SEND A SHIP"
	b_2.text = "STATS"
	b_3.text = "GO UP"
	set_control_screen(null)

func buy_drone():
	if Global.radar_controller.try_add_drone():
		if Global.try_consume_load(20.0):
			set_stats_screen()
		else:
			not_enough_to_buy()
	else:
		not_enough_to_buy("Maximum Drone\nCapacity Reached")

func repair_hull():
	if Global.add_health(1):
		if Global.try_consume_load(20.0):
			set_stats_screen()
		else:
			not_enough_to_buy()
	else:
		not_enough_to_buy("Hull Integrity\nAlready Optimal" )

func not_enough_to_buy(m := ""):
	var msg = "Not Enough
				To Buy This"
	if m != "":
		load_bar.hide()
		msg = m
	else:
		var load_value = Global.cur_load / Global.max_load
		animate_load_bar(load_bar, load_value)
	label_hp.hide()
	label_fuel.hide()
	play_label_effect(label_load, msg)

func exit_station():
	Global.exit_station()

var can_goup := false
var going_up := false
var target_depth : int

func set_ascend_screen():
	hud_control.hide()
	hud_send.hide()
	hud_stats.hide()
	hud_goup.show()
	var msg := "Fuel Not Full
				Gather Cells
				with Drones"
	if can_goup:
		target_depth = -((5 - Global.main.cur_lvl_id) * 25000)
		msg = "Reaching level\n%d m\nHold steady..." % target_depth
		going_up = true
	if not can_goup and Global.cur_fuel >= Global.max_fuel:
		msg = "Systems Ready
				Confirm Again
				to Ascend"
		can_goup = true
	play_label_effect(label_goup, msg)

func _physics_process(delta: float) -> void:
	if going_up:
		Global.radar_controller.monitor.trauma = 0.15
		goingup_bar.value += delta * 15.0
		if goingup_bar.value >= goingup_bar.max_value:
			Global.ascend()
			play_label_effect(label_goup, "Arrived at depth\n%d m" % target_depth)
			going_up = false
			can_goup = false
	else:
		goingup_bar.value = 0.0

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

func animate_load_bar(bar: ProgressBar, target_value: float, duration: float = 0.8) -> void:
	load_bar.show()
	load_bar.value = 0.0
	#await get_tree().create_timer(0.3, false, true, true).timeout
	if bar.has_meta("tween") and is_instance_valid(bar.get_meta("tween")):
		var old_tween = bar.get_meta("tween")
		old_tween.kill()
	bar.value = 0
	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	bar.set_meta("tween", tween)

	# animate from 0 to target_value
	tween.tween_property(bar, "value", target_value * bar.max_value, duration).as_relative()
