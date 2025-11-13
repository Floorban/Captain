extends Button
class_name Upgrade

@export var max_boughts := 1
var bought_times := 0
@export var upgrade_type: String
@export var cost := 20
@export var fuel_cost := 0.0
var on_buy: Callable

func _ready() -> void:
	if Global.upgrade_effects.has(upgrade_type):
		on_buy = Global.upgrade_effects[upgrade_type]
	else:
		on_buy = func(): print("upgrade type not found: ", upgrade_type)
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if Global.try_consume_load(cost) and Global.try_consume_fuel(fuel_cost):
		on_buy.call()
		bought_times += 1
		Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UPGRADE)
		Global.update_stats()
		if is_sold_out():
			queue_free()
	else:
		Global.game_controller.side_screen.not_enough_to_buy()

func is_sold_out() -> bool:
	return bought_times >= max_boughts
