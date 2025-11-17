extends Window
class_name SubWindow

@onready var player: Player = $Player
@onready var button_drop: Button = %ButtonDrop
@onready var signals : Array[Node] = [$UI/ShipUI/MarginContainer/Signal_0, $UI/ShipUI/MarginContainer/Signal_1, $UI/ShipUI/MarginContainer/Signal_2]
var thresholds = []

@export var death_mat: Material
@onready var death_menu: ColorRect = %DeathMenu
@onready var screen_label: Label = $UI/ShipUI/DeathMenu/LabelDeath

func _ready() -> void:
	_get_signal_screen_effect_mat(death_mat)

func init_window(window_id: int, window_pos_x: float, window_pos_y: float, world_pos: Vector2):
	position.x = int(window_pos_x)
	position.y = int(window_pos_y)
	resize_window(Global.drone_vision_scale)
	init_player(window_id, world_pos)

func init_player(id: int, target_pos: Vector2):
	if not player: return
	update_player_upgrades(player)
	player.init_player_input_keys("up"+str(id), "left"+str(id), "down"+str(id), "right"+str(id), str(id))
	button_drop.text = "Press " + player.drop_key + "\nTo Drop"
	
	player.global_position = target_pos
	player.health_component.set_cur_hp(player.health_component.max_hp)
	#TODO: add player in the dictionry instead of asking for refreshing all the markers
	Global.main.mini_map.get_minimap_objs()
	signal_connected()

func update_player_upgrades(p: Player, speed_bonus: float = Global.added_player_hp, max_hp_bonus: int = Global.added_player_hp):
	p.move_speed += speed_bonus
	p.health_component.max_hp += max_hp_bonus

func _process(_delta: float) -> void:
	if thresholds.size() <= 0 or not player or player.is_dead: return
	update_signal_distance_indicator(player, Global.get_captain())

func update_signal_distance_indicator(a: Node2D, b: Node2D) -> void:
	var dist = a.global_position.distance_to(b.global_position)
	for i in range(signals.size()):
		signals[i].visible = dist <= thresholds[i]

func resize_window(size_scale: Vector2i):
	unresizable = false
	size *= size_scale
	unresizable = true

func signal_connected():
	_signal_screen_effect(true)
	var max_dist = Global.get_captain().drone_area.col.radius
	thresholds = [max_dist*0.9, max_dist*0.5, max_dist*0.1]

func signal_lost(recycle := false):
	_signal_screen_effect(false)
	if player.is_dead:
		Global.play_label_effect(screen_label, "DRONE IS \nDAMAGED")
	elif recycle: 
		Global.play_label_effect(screen_label, "CREW HAS RETURNED\n SUCCESSFULLY")
	else: 
		Global.play_label_effect(screen_label, "SIGNAL LOST... \nPLEASE STAY IN THE \nCAPTAIN SIGNAL RANGE")
		Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.DRONE_DISCONNECT)

func _clear_window(captain_dead := false):
	Global.windows_manager.remove_subwindow(self)
	_signal_screen_effect(false)
	if captain_dead:
		screen_label.show()
		screen_label.text = "LOST CONNECTION\n WITH CAPTAIN..."
	else:
		Global.play_label_effect(screen_label, "DRONE IS \nDAMAGED")
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _get_signal_screen_effect_mat(base_mat: Material):
	var mat = base_mat.duplicate()
	death_menu.material = mat

func _signal_screen_effect(connected: bool):
	var tween = create_tween()
	if connected:
		screen_label.hide()
		tween.tween_property(death_menu.material, "shader_parameter/shake", 0.01, 0.1)
		tween.tween_property(death_menu.material, "shader_parameter/pixelSize", 500.0, 0.3)
		tween.tween_property(death_menu.material, "shader_parameter/grainIntensity", 0.02, 0.2)
		tween.tween_property(death_menu.material, "shader_parameter/lens_distortion_strength", 0.01, 0.1)
		Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.DRONE_CONNECT)
	else:
		screen_label.show()
		tween.tween_property(death_menu.material, "shader_parameter/shake", 10.0, 0.1)
		tween.tween_property(death_menu.material, "shader_parameter/pixelSize", 60.0, 0.3)
		tween.tween_property(death_menu.material, "shader_parameter/grainIntensity", 0.9, 0.2)
		tween.tween_property(death_menu.material, "shader_parameter/lens_distortion_strength", 0.1, 0.1)
