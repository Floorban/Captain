extends Node
class_name WindowManager

@onready var main_window: Window = get_window()
@export var window_scene: PackedScene
@export var main_sub_window: Window
var subwindows: Array[SubWindow] = []

func _ready():
	Global.windows_manager = self
	_init_main_window()
	_connect_main_sub_window_to_world()

func _init_main_window():
	main_window.gui_embed_subwindows = false
	main_window.borderless = true
	main_window.unresizable = true
	main_window.transparent = true
	main_window.transparent_bg = true
	main_window.min_size = Vector2.ZERO
	main_window.size = Vector2.ZERO

func _connect_main_sub_window_to_world():
	main_sub_window.world_2d = main_window.world_2d
	main_sub_window.grab_focus()

func spawn_window(world_pos: Vector2):
	if not window_scene:
		return
	var w = window_scene.instantiate()
	if w is SubWindow:
		w.world_2d = main_window.world_2d
		w.tree_exited.connect(func():
			subwindows.erase(w)
			print("Removed window:", w.name)
		)
		add_child(w)
		subwindows.append(w)
		w.name = "SubWindow_%d" % subwindows.size()
		w.title = "Crew_%d" % subwindows.size()
		var index = subwindows.size() - 1
		var fixed_positions = get_window_spawn_positions(w)
		var spawn_pos = fixed_positions[index % fixed_positions.size()]
		w.init_window(spawn_pos.x, spawn_pos.y, world_pos)

func get_window_spawn_positions(w: Window) -> Array:
	var screen_size = DisplayServer.screen_get_size()
	var size := subwindows.size()
	var y : float = (screen_size.y - w.size.y) / 2
	var spacing : float = float(main_sub_window.size.x)
	var center_x = (screen_size.x - w.size.x + spacing) / 2
	return [
		Vector2(center_x - spacing, y),
		Vector2(center_x + spacing, y)
	]

func set_windows_visibility(enable: bool):
	if subwindows.size() <= 0:
		return
	for w in subwindows:
		if not enable: w.hide()
		else: w.show()

func close_all_windows():
	var delay := randf_range(0.8, 1.2)
	for w in subwindows:
		if is_instance_valid(w):
			w._clear_window(true)
			await get_tree().create_timer(delay).timeout
	subwindows.clear()
