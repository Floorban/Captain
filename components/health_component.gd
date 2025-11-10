extends Node2D
class_name HealthComponent

signal hp_changed(new_hp: int)
signal died

@export var max_hp: int = 4
var cur_hp: int : set = set_cur_hp, get = get_cur_hp
@export var health_bar: HealthBar

func init_hp() -> void:
	cur_hp = max_hp
	emit_signal("hp_changed", cur_hp)

func get_cur_hp() -> int:
	return cur_hp

func set_cur_hp(value: int) -> void:
	cur_hp = clamp(value, 0, max_hp)
	if health_bar: health_bar.update_hp_bar(cur_hp)
	emit_signal("hp_changed", cur_hp)
	if cur_hp == 0:
		emit_signal("died")

func take_damage(attack: AttackComponent) -> void:
	set_cur_hp(cur_hp - attack.attack_damage)
