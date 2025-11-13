extends Window
class_name Wwindow

@export var width_range: Vector2i = Vector2i(400, 400)
@export var height_range: Vector2i = Vector2i(400, 400)

@export var max_distance: float = 500.0  # beyond this, window is minimum size
@export var min_window_size: Vector2i = Vector2i(250, 250)

var size_tween : Tween

@onready var player: Player = $Player
@onready var button_drop: Button = %ButtonDrop
@onready var inventory_component: InventoryComponent = %InventoryComponent
@onready var death_menu: ColorRect = %DeathMenu
@onready var label_death: Label = $UI/ShipUI/DeathMenu/LabelDeath
@export var death_mat: Material

func random_size() -> Vector2i:
	return Vector2(randi_range(width_range.x, width_range.y), randi_range(height_range.x, height_range.y))

func init_window(_x: float, _y: float, _t: Vector2):
	position.x = int(_x)
	position.y = int(_y)
	player.hide()
	#await get_tree().create_timer(delay).timeout
	init_player(_t)

	#if not player or not is_instance_valid(player) or not Global.get_captain():
		#return
	#var dist := player.global_transform.origin.distance_to(Global.get_captain().global_transform.origin)
	#var t : float = clamp(dist / max_distance, 0.0, 1.0)  # 0 = close, 1 = far
#
	#var target_w = lerp(width_range.y, width_range.x, t)
	#var target_h = lerp(height_range.y, height_range.x, t)
	#var target_size = Vector2i(target_w, target_h)
	#resize_window(target_size)

func init_player(target_pos: Vector2):
	if not player: return
	button_drop.pressed.connect(try_drop)
	player.show()
	player.global_position = target_pos
	Global.main.mini_map.get_minimap_objs()

func init_window_signals():
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	close_requested.connect(_clear_window)

func _ready() -> void:
	init_window_signals()
	var mat = death_mat.duplicate()
	death_menu.material = mat

func resize_window(target_size: Vector2i):
	unresizable = false
	if size_tween and size_tween.is_running():
		size_tween.kill()

	size_tween = create_tween()
	size_tween.tween_property(self, "size", target_size, 0.2)
	#.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	size_tween.finished.connect(func(): unresizable = true)
	
	check_window_size()

func check_window_size():
	if size.y <= min_window_size.y:
		if visible:
			Global.windows_manager.main_sub_window.grab_focus()
			visible = false

func try_drop():
	inventory_component.drop_item(player.global_position + Vector2(randf_range(-30,30), randf_range(-30,30)))

func signal_lost():
	#death_menu.show()
	if player.health_component.cur_hp > 0:
		var tween = create_tween()
		tween.tween_property(death_menu.material, "shader_parameter/shake", 10.0, 0.1)
		tween.tween_property(death_menu.material, "shader_parameter/pixelSize", 60.0, 0.3)
		tween.tween_property(death_menu.material, "shader_parameter/grainIntensity", 0.9, 0.2)
		tween.tween_property(death_menu.material, "shader_parameter/lens_distortion_strength", 0.1, 0.1)
		
		Global.game_controller.side_screen.play_label_effect(label_death, "SIGNAL IS \nDISCONNECTED")
	else:
		_clear_window()

func signal_recover():
	#death_menu.hide()
	label_death.hide()
	var tween = create_tween()
	tween.tween_property(death_menu.material, "shader_parameter/shake", 0.01, 0.1)
	tween.tween_property(death_menu.material, "shader_parameter/pixelSize", 500.0, 0.3)
	tween.tween_property(death_menu.material, "shader_parameter/grainIntensity", 0.02, 0.2)
	tween.tween_property(death_menu.material, "shader_parameter/lens_distortion_strength", 0.01, 0.1)

func _on_focus_entered() -> void:
	if player: player.can_control = true
	button_drop.grab_focus()
	#if has_focus(): resize_window(size*0.8)

func _on_focus_exited() -> void:
	if player: player.can_control = false

func _clear_window(captain_dead := false):
	var tween = create_tween()
	tween.tween_property(death_menu.material, "shader_parameter/shake", 10.0, 0.1)
	tween.tween_property(death_menu.material, "shader_parameter/pixelSize", 60.0, 0.3)
	tween.tween_property(death_menu.material, "shader_parameter/grainIntensity", 0.9, 0.2)
	tween.tween_property(death_menu.material, "shader_parameter/lens_distortion_strength", 0.1, 0.1)
	if captain_dead:
		label_death.show()
		label_death.text = "SIGNAL LOST..."
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		Global.game_controller.side_screen.play_label_effect(label_death, "DRONE IS \nDAMAGED")
		await get_tree().create_timer(3.5).timeout
		queue_free()
