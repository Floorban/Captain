extends Node

@onready var _MainWindow: Window = get_window()
@export var _MainSubWindow: Window
@export var _SubWindow1: Window
@export var _SubWindow2: Window
@export var player_size: Vector2i = Vector2i(32, 32)

func _ready():
#sharing the same world as subwindow
	_MainSubWindow.world_2d = _MainWindow.world_2d
	if _SubWindow1: _SubWindow1.world_2d = _MainWindow.world_2d
	if _SubWindow2: _SubWindow2.world_2d = _MainWindow.world_2d
# declare the variables...

		# Enable per-pixel transparency, required for transparent windows but has a performance cost
		# Can also break on some systems
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
		# Set the window settings - most of them can be set in the project settings
	_MainWindow.borderless = true		# Hide the edges of the window
	_MainWindow.unresizable = true		# Prevent resizing the window
	_MainWindow.always_on_top = true	# Force the window always be on top of the screen
	_MainWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	_MainWindow.transparent = true		# Allow the window to be transparent
		# Settings that cannot be set in project settings
	_MainWindow.transparent_bg = true	# Make the window's background transparent
		
		# set the subwindow's world...
		# The window's size may need to be smaller than the default minimum size
	# so we have to change the minimum size BEFORE setting the window's size
	_MainWindow.min_size = player_size
	_MainWindow.size = _MainWindow.min_size

	# set the subwindow's world...
