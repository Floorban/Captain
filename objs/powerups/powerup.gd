extends CharacterBody2D
class_name Powerup

@onready var interaction: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction.interact = Callable(self, "_on_pickup")

func _on_pickup(interactor: Node) -> void:
	if interactor.has_node("HitboxComponent"):
		var hb = interactor.get_node("HitboxComponent") as HitboxComponent
		hb.has_shield = true
	call_deferred("queue_free")
