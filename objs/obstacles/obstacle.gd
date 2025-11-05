extends CharacterBody2D
class_name Obstacle

@export var min_speed: float = 50.0
@export var max_speed: float = 200.0
var speed: float

func _ready() -> void:
	rotation_degrees = randf() * 360.0
	speed = randf_range(min_speed, max_speed)

func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, speed)
	move_and_slide()
