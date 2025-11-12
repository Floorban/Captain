extends Node2D
class_name  RadarObjComponent

@onready var icon: Sprite2D = $MiniMapIcon
@export var is_detectable := false
@onready var display_name = get_parent().name
@onready var display_color = Color.GREEN
