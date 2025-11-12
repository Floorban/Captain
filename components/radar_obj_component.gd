extends Node2D
class_name  RadarObjComponent

@onready var icon: Sprite2D = $MiniMapIcon
@export var is_detectable := false
@export var display_name : String
@onready var display_color = Color.GREEN
