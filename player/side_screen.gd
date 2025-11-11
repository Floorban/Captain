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

@onready var hud_goup: Control = $SubViewport/Background/GameMenu/Panel/HUD_GOUP

func bind_button_to_menu(id:int):
	Global.game_controller.set_game_menu_content(id)

func set_main_menu():
	main_menu.show()
	game_menu.hide()
	button_1.grab_focus()
	button_1.pressed.connect(bind_button_to_menu.bind(0))
	button_2.pressed.connect(bind_button_to_menu.bind(1))
	button_3.pressed.connect(bind_button_to_menu.bind(2))
	button_4.pressed.connect(bind_button_to_menu.bind(3))
	button_1.text = "ABOUT"
	button_2.text = "CONTROL1"
	button_3.text = "CONTROL2"
	button_4.text = "START"

func set_game_menu():
	main_menu.hide()
	game_menu.show()
	b_1.grab_focus()
	set_control_screen(null, true)
	b_1.pressed.connect(set_send_screen) 
	b_2.pressed.connect(set_stats_screen)
	b_3.pressed.connect(set_ascend_screen)
	b_1.text = "SEND A SHIP"
	b_2.text = "STATS"
	b_3.text = "GO UP"

func set_control_screen(found_target: Station, first_time := false):
	hud_control.show()
	hud_send.hide()
	hud_stats.hide()
	hud_goup.hide()
	label_control.hide()
	label_detection.hide()
	if found_target:
		label_detection.text = ""
		label_detection.show()
		var pos := found_target.global_position
		var msg = "Station Detected\n(%d, %d)\n%s" % [
			int(pos.x),
			int(pos.y),
		    "Be Careful"
		]
		play_label_effect(label_detection, msg)
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
				HP & FUEL"
			]
		var msg = messages.pick_random()
		label_control.text = ""
		label_control.show()
		play_label_effect(label_control, msg)

func set_send_screen():
	hud_control.hide()
	hud_send.show()
	hud_stats.hide()
	hud_goup.hide()
	label_send.text = "Target Required"
	Global.radar_controller.send_ship(b_1, send_ship_bar, label_send)

func set_stats_screen():
	hud_control.hide()
	hud_send.hide()
	hud_stats.show()
	hud_goup.hide()

func set_ascend_screen():
	hud_control.hide()
	hud_send.hide()
	hud_stats.hide()
	hud_goup.show()

func play_label_effect(label: Label, full_text: String) -> void:
	label.text = ""
	label.show()
	await _blink_label(label, 6, 0.05, 0.15)
	await _type_glitch(label, full_text, 0.03, 0.5)

func _blink_label(label: Label, blinks: int, min_delay: float, max_delay: float) -> void:
	for i in range(blinks):
		label.visible = not label.visible
		await get_tree().create_timer(randf_range(min_delay, max_delay)).timeout
	label.visible = true

func _type_glitch(label: Label, text: String, char_delay: float, glitch_chance: float) -> void:
	var output := ""
	var chars = text.split("")  # characters
	for c in chars:
		if randf() < glitch_chance:
			label.text = output + _random_glitch_char()
			await get_tree().create_timer(char_delay * 0.5).timeout
		output += c
		label.text = output
		await get_tree().create_timer(char_delay).timeout

func _random_glitch_char() -> String:
	var pool = ["#", "%", "&", "*", "@", "?", "/", "\\", "!", "~", "±", "§"]
	return pool[randi() % pool.size()]
