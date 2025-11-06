extends Node2D
class_name Station

@onready var icon: Sprite2D = %Icon
@onready var interaction: InteractionComponent = $InteractionComponent
var has_entered := false

func _ready() -> void:
	interaction.interact = Callable(self, "_on_enter_station")

func _on_enter_station(_interactor: Node) -> void:
	#if interactor.has_node("InventoryComponent"): #if player's reputation is over 10 or some lol
	if has_entered:
		return
	has_entered = true
	Global.enter_station(self)
