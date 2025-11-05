extends Node2D
class_name Station

@onready var icon: Sprite2D = %Icon
@onready var interaction: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction.interact = Callable(self, "_on_enter_station")

func _on_enter_station(interactor: Node) -> void:
	#if interactor.has_node("InventoryComponent"): #if player's reputation is over 10 or some lol
	Global.enter_station(self)
