extends Node3D
class_name Monitor

@onready var blades: MeshInstance3D = $Env/Ventilation_2/Ventilation_2_blades
@onready var camera: Camera3D = $Camera3D
@onready var screen: Sprite3D = $"Collada visual scene group/Cube/Screen"
@onready var mini_map: MiniMap = %MiniMap

var target_speed := 0.0 
var current_speed := 0.0
var accel := 0.8

func _ready() -> void:
	screen.texture.viewport_path = mini_map.sub_viewport.get_path()

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
