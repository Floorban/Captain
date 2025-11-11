extends Area2D
class_name DetectionArea

@onready var detection_radius: Sprite2D = $DetectionRadius
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func grow_detection_radius(_scale: float):
	apply_scale(Vector2(_scale, _scale))
