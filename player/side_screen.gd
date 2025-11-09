extends SubViewportContainer

@onready var button_1: Button = %Button1
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4

func _ready() -> void:
	set_maun_menu()

func set_maun_menu():
	button_1.grab_focus()
	button_1.text = "CONTROL"
	button_2.text = "START"
	button_3.text = "CREDITS"
	button_4.text = "NOTHIN"

func set_game_menu():
	button_1.grab_focus()
	button_1.text = "NAVIGATE"
	button_2.text = "SEND X"
	button_3.text = "INVENTORY"
	button_4.text = "INVENTORY"
