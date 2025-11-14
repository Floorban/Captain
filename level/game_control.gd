extends CanvasLayer
class_name GameControl

var paused := true

@onready var main: Main = %Main
@onready var select_marker: SelectMarker = %SelectMarker
@onready var mini_map: MiniMap = %MiniMap
@onready var side_screen: SideScreen = %SideScreen
@onready var retro_effect_rect: ColorRect = %RetroEffectRect
@onready var credits: Panel = %Credits

var in_main_menu := false
var in_game := false

@onready var hp_bar: HealthBar = %HpBar
@onready var fuel_bar: ProgressBar = %FuelBar
@onready var win: Panel = %Win

func _ready() -> void:
	Global.game_controller = self
	get_tree().paused = true

func set_game_menu_content(menu_id: int):
	if credits.visible:
		credits.hide()
	if not in_main_menu:
		hp_bar.hide()
		fuel_bar.hide()
		side_screen.set_main_menu()
		main.hide()
		select_marker.hide()
		Global.radar_controller.can_control = false
		in_main_menu = true
		in_game = false
		retro_effect_rect.show()
	mini_map.set_menu(menu_id)

func set_game_content():
	if credits.visible:
		credits.hide()
	if not in_game:
		hp_bar.show()
		fuel_bar.show()
		side_screen.set_game_menu()
		main.show()
		select_marker.show()
		Global.radar_controller.can_control = true
		in_game = true
		in_main_menu = false
		retro_effect_rect.hide()
	mini_map.set_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if paused:
			get_tree().paused = false
			paused = false
			if not in_game:
				set_game_menu_content(0)
			elif in_game:
				set_game_content()
		else:
			paused = true
			get_tree().paused = true
			credits.show()
