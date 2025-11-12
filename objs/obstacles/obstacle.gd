extends CharacterBody2D
class_name Obstacle

@export var min_speed: float = 5.0
@export var max_speed: float = 50.0
var speed: float
@onready var radar_obj_component: RadarObjComponent = $RadarObjComponent

func _ready() -> void:
	radar_obj_component.display_name = "Reef"
	radar_obj_component.display_color = Color.RED
	rotation_degrees = randf() * 360.0
	speed = randf_range(min_speed, max_speed)

func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, speed)
	move_and_slide()
	
