extends Area2D
class_name InteractionComponent

@export var need_input := false
@export var interact_name := "Pickup"
@export var interact_duration := 1.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Node) -> void:
	if area is InteractionController:
		area.register_area(self)

func _on_area_exited(area: Node) -> void:
	if area is InteractionController:
		area.unregister_area(self)

var interact: Callable = func(_interactor : Node):
	pass
