extends Area2D
class_name HitboxComponent

signal hit()
signal turn_invulnerable(invulnerable: bool)

@export var health_component : HealthComponent
@export var knockback_node : CharacterBody2D
var is_invulnerable := false : set = apply_invulnerablity

func apply_damage(attack: AttackComponent) -> void:
	hit.emit()
	if is_invulnerable:
		is_invulnerable = false
		return
	if health_component: health_component.take_damage(attack)
	if knockback_node:
		_apply_knockback(attack)

func _apply_knockback(attack: AttackComponent) -> void:
	if not knockback_node.has_method("apply_knockback"):
		return
	
	var direction = (global_position - attack.global_position).normalized()
	knockback_node.apply_knockback(direction, attack.attack_knockback, attack.stun_time)

func apply_invulnerablity(vulnerability: bool):
	turn_invulnerable.emit(vulnerability)
	if vulnerability:
		is_invulnerable = true
	else:
		is_invulnerable = false
