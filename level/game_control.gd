extends CanvasLayer
class_name GameControl

@onready var main: Main = %Main
@onready var select_marker: SelectMarker = %SelectMarker
@onready var mini_map: MiniMap = %MiniMap
@onready var side_screen: SideScreen = %SideScreen
@onready var retro_effect_rect: ColorRect = %RetroEffectRect

var in_main_menu := false
var in_game := false

func _ready() -> void:
	Global.game_controller = self
	#set_game_content()
	set_game_menu_content(0)

func set_game_menu_content(menu_id: int):
	if not in_main_menu:
		side_screen.set_main_menu()
		main.hide()
		select_marker.hide()
		Global.radar_controller.can_control = false
		in_main_menu = true
		in_game = false
		retro_effect_rect.show()
	mini_map.set_menu(menu_id)

func set_game_content():
	if not in_game:
		side_screen.set_game_menu()
		main.show()
		select_marker.show()
		Global.radar_controller.can_control = true
		in_game = true
		in_main_menu = false
		retro_effect_rect.hide()
	mini_map.set_game()
