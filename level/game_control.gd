extends CanvasLayer
class_name GameControl

@onready var main: Main = %Main
@onready var select_marker: SelectMarker = %SelectMarker
@onready var camera_controller: RadarController = %MiniMapCamera
@onready var mini_map: MiniMap = %MiniMap
@onready var side_screen: SubViewportContainer = %SideScreen

func _ready() -> void:
	Global.game_controller = self
	set_game_menu_content()

func set_game_menu_content():
	main.hide()
	select_marker.hide()
	mini_map.radar.hide()
	camera_controller.can_control = false

func set_game_content():
	main.show()
	select_marker.show()
	mini_map.radar.show()
	camera_controller.can_control = true
