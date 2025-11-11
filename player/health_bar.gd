extends ProgressBar
class_name HealthBar

var health_component: HealthComponent
#@export var frame_width: int = 48

func update_hp_bar(cur_hp: int) -> void:
	if health_component == null: return
	var hp_ratio : float = clamp(float(cur_hp) / float(health_component.max_hp), 0.0, 1.0)
	value = hp_ratio * max_value
	#var t := texture as AtlasTexture
	#if t == null:
		#return
	#var frame_index := int(ceil((1.0 - hp_ratio) * (health_component.max_hp - 1)))
	#if hp_ratio == 0: frame_index = health_component.max_hp
	#var region := t.region
	#region.position.x = frame_index * frame_width
	#t.region = region
