extends Node
class_name WindowManager

@onready var main_window: Window = get_window()
@export var window_scene: PackedScene
@export var spawn_area: Vector2 = Vector2(1500, 800)
@export var main_sub_window: Window
var subwindows: Array[Wwindow] = []

func _ready():
	Global.windows_manager = self
	_init_main_window()
	main_sub_window.files_dropped.connect(_on_files_dropped)
	main_sub_window.world_2d = main_window.world_2d
	var screen_size = DisplayServer.screen_get_size()
	main_sub_window.position = Vector2(
		screen_size.x -main_sub_window.size.x - 50,
		screen_size.y - main_sub_window.size.y - 50
	)
	main_sub_window.grab_focus()

func _init_main_window():
	main_window.gui_embed_subwindows = false
	main_window.borderless = true
	main_window.unresizable = true
	main_window.transparent = true
	main_window.transparent_bg = true
	main_window.min_size = Vector2.ZERO
	main_window.size = Vector2.ZERO

func spawn_window(pos: Vector2):
	if not window_scene:
		return

	var w = window_scene.instantiate()
	if w is Wwindow:
		w.world_2d = main_window.world_2d
		w.tree_exited.connect(func():
			subwindows.erase(w)
			print("Removed window:", w.name)
		)
		w.name = "SubWindow_%d" % subwindows.size()
		add_child(w)
		subwindows.append(w)
		var index = subwindows.size() - 1
		var fixed_positions = get_fixed_positions_top_row(w)
		var spawn_pos = fixed_positions[index % fixed_positions.size()]
		w.init_window(spawn_pos.x, spawn_pos.y, pos)

func get_fixed_positions_top_row(w) -> Array:
	var screen_size = DisplayServer.screen_get_size()
	var y = 30  # distance from top edge
	var spacing = 500  # horizontal spacing from the center

	var center_x = (screen_size.x - w.size.x) / 2
	return [
		Vector2(center_x - spacing, y),
		Vector2(center_x, y),
		Vector2(center_x + spacing, y)
	]

func close_all_windows():
	var delay := randf_range(0.8, 1.2)
	for w in subwindows:
		if is_instance_valid(w):
			w._clear_window(true)
			await get_tree().create_timer(delay).timeout
	subwindows.clear()
	main_sub_window.queue_free()
	get_tree().call_deferred("quit")

func _on_files_dropped(files: PackedStringArray):
	for f in files:
		print("File dropped:", f)
		check_file(f)

func check_file(f: String):
	var fname = f.get_file()
	if fname == "start.txt":
		delete_file(f)
		Global.game_controller.set_game_menu_content(0)
		#spawn resource in the game

func delete_file(path: String) -> void:
	var dir := DirAccess.open(path.get_base_dir())
	if dir and dir.file_exists(path.get_file()):
		dir.remove(path.get_file())
	#var err := DirAccess.remove_absolute(path)
	#if err != OK:
		#push_warning("Could not delete file: %s" % path)
