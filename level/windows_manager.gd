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

func _init_main_window():
	main_window.gui_embed_subwindows = false
	main_window.borderless = true
	main_window.unresizable = true
	main_window.transparent = true
	main_window.transparent_bg = true
	main_window.min_size = Vector2.ZERO
	main_window.size = Vector2.ZERO

func spawn_window():
	if not window_scene:
		return

	var w = window_scene.instantiate()
	if w is Wwindow:
		var x = randf_range(0, spawn_area.x)
		var y = randf_range(0, spawn_area.y)
		w.init_window(x, y)

		w.world_2d = main_window.world_2d
		subwindows.append(w)
		w.tree_exited.connect(func():
			subwindows.erase(w)
			print("Removed window:", w.name)
		)
		
		w.name = "SubWindow_%d" % subwindows.size()
		add_child(w)

func close_all_windows():
	for w in subwindows:
		if is_instance_valid(w):
			w.visible = false
	subwindows.clear()


func _on_files_dropped(files: PackedStringArray):
	for f in files:
		print("File dropped:", f)
		check_file(f)

func check_file(f: String):
	#var fname = f.get_file()
	#if fname == "new.txt" or fname == "1.txt":
	delete_file(f)
		#spawn resource in the game

func delete_file(path: String) -> void:
	var dir := DirAccess.open(path.get_base_dir())
	if dir and dir.file_exists(path.get_file()):
		dir.remove(path.get_file())
	#var err := DirAccess.remove_absolute(path)
	#if err != OK:
		#push_warning("Could not delete file: %s" % path)
