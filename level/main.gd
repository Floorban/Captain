extends Node2D
class_name Main

@onready var root: Root = get_tree().get_first_node_in_group("root")

@export var is_paused := false
@export var game_speed := 20.0

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	global_position.y += game_speed * delta
