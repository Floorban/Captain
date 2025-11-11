extends Node3D
class_name Monitor

@onready var blades: MeshInstance3D = $Env/Ventilation_2/Ventilation_2_blades
@onready var camera: Camera3D = $Camera3D
@onready var screen: Sprite3D = $"Collada visual scene group/Cube/Screen"
@onready var side_screen: Sprite3D = $"Collada visual scene group/Cube_017/SideScreen"
@onready var mini_map: MiniMap = %MiniMap

var target_speed := 0.0 
var current_speed := 0.0
var accel := 0.8

@onready var lights: Array[Node3D] = [%Light1, %Light2, %Light3]

@onready var danger_light: Node3D = %danger_light
var danger_blinking := false

@onready var navigate_light: Node3D = %navigate_light

func _ready() -> void:
	screen.texture.viewport_path = mini_map.sub_viewport.get_path()
	side_screen.texture.viewport_path = mini_map.side_sub_viewport.get_path()

func _process(delta: float) -> void:
	update_cam_shake(delta)
	current_speed = lerp(current_speed, target_speed, delta * accel)
	blades.rotate_z(current_speed * delta)

# Camera Shake
var decay: = 0.8
var max_offset: = Vector3(0.5, 0.5, 0.5)
var max_rotation: = Vector3(1.0, 1.0, 1.0) # degrees
var trauma: = 0.0
var trauma_power: = 2
@onready var cam_original_position: Vector3 = camera.global_position
@onready var cam_original_rotation: Vector3 = camera.global_rotation

func update_cam_shake(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		cam_shake()
	else:
		camera.position = cam_original_position
		camera.rotation_degrees = cam_original_rotation

func cam_shake() -> void:
	var amount = pow(trauma, trauma_power)
	var _offset = Vector3(
		max_offset.x * amount * randf_range(-1.0, 1.0),
		max_offset.y * amount * randf_range(-1.0, 1.0),
		max_offset.z * amount * randf_range(-1.0, 1.0)
	)
	var _rotation = Vector3(
		max_rotation.x * amount * randf_range(-1.0, 1.0),
		max_rotation.y * amount * randf_range(-1.0, 1.0),
		max_rotation.z * amount * randf_range(-1.0, 1.0)
	)
	
	camera.position = cam_original_position + _offset
	camera.rotation_degrees = cam_original_rotation + _rotation

func switch_light(index: int, turn_on := false, blink_times := 5, blink_speed := 0.08):
	index = clampi(index, 0, 2)
	lights[index].show()
	var off_light = lights[index].get_child(0)
	var real_light = lights[index].get_child(1)
	blink_light(off_light, real_light, turn_on, blink_times, blink_speed)

func blink_light(
	off_light: Node,
	real_light: Node,
	final_on: bool,
	blink_times: int,
	blink_speed: float,
	blink_times_random := 3,
	blink_speed_variation := 0.5
) -> void:
	var total_blinks := blink_times + randi_range(-blink_times_random, blink_times_random)
	total_blinks = max(total_blinks, 1)  # ensure at least 1 blink

	for i in range(total_blinks):
		var is_on = i % 2 == 0
		if is_on:
			real_light.show()
			off_light.hide()
		else:
			real_light.hide()
			off_light.show()

		var offset := randf_range(-blink_speed * blink_speed_variation, blink_speed * blink_speed_variation)
		var delay : float = max(0.02, blink_speed + offset)
		await get_tree().create_timer(delay).timeout

	# final stable state
	if final_on:
		real_light.show()
		off_light.hide()
	else:
		real_light.hide()
		off_light.show()

func start_danger_blink():
	if danger_blinking:
		return
	danger_blinking = true
	blink_danger_light()

func stop_danger_blink():
	danger_blinking = false

func blink_danger_light() -> void:
	while danger_blinking:
		danger_light.visible = !danger_light.visible
		var delay := randf_range(0.15, 0.3)
		await get_tree().create_timer(delay).timeout
	danger_light.visible = false

func switch_nagivate_light(on: bool):
	if on: navigate_light.show()
	else: navigate_light.hide()
