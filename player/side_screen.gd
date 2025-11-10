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
	b_1.pressed.connect(set_send_screen) 
	b_2.pressed.connect(set_stats_screen)
	b_3.pressed.connect(set_control_screen)
	b_1.text = "SEND A SHIP"
	b_2.text = "STATS"
	b_3.text = "GO UP"

func set_control_screen():
	hud_control.show()
	hud_send.hide()
	hud_stats.hide()

func set_send_screen():
	hud_control.hide()
	hud_send.show()
	hud_stats.hide()
	label_send.text = "SELECT A \n DESTINATION"
	Global.radar_controller.send_ship(b_1, send_ship_bar, label_send)

func set_stats_screen():
	hud_control.hide()
	hud_send.hide()
	hud_stats.show()

func set_ascend_screen():
	pass
