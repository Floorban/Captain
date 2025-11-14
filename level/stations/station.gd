extends Node2D
class_name Station

@export var is_exit := false
@onready var icon: Sprite2D = %Icon
@onready var interaction: InteractionComponent = $InteractionComponent
var has_entered := false

@export var axis: Vector2
@onready var radar_obj_component: RadarObjComponent = $RadarObjComponent

func _ready() -> void:
	interaction.connect("area_exited", _on_exit_station)
	interaction.interact = Callable(self, "_on_enter_station")
	radar_obj_component.display_name = name

func _on_enter_station(_interactor: Node) -> void:
	if is_exit:
		Global.game_win()
		return
	if has_entered:
		return
	interaction.can_interact = false
	has_entered = true
	Global.enter_station(self)

func _on_exit_station(_interactor: Node2D):
	has_entered = false
