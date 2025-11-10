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
	b_1.text = "SEND A SHIP"
	b_2.text = "GO UP"
	b_3.text = "STATS"
