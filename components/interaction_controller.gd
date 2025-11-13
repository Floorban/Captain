extends Area2D
class_name InteractionController

@onready var label: Label = %Label
@onready var interact_progress_bar: TextureProgressBar = %InteractProgressBar

var active_areas: Array[InteractionComponent] = []
@export var can_interact = true

var current_pickup: InteractionComponent = null
var pickup_timer := 0.0
var pickup_speed := 1.0
#var waiting_for_input := false

func _ready() -> void:
	interact_progress_bar.hide()
	label.hide()

func _process(delta: float) -> void:
	label.global_position += global_position
	# Wait for input if needed
	#if waiting_for_input and current_pickup != null:
		#pickup_timer = 0.0
		#_update_ui(delta)
		#label.text = current_pickup.interact_name
		#label.global_position = current_pickup.global_position + Vector2(-label.size.x / 2, -24)
		#label.show()
		## Wait for interaction key
		#if Input.is_action_just_pressed("scan"):
			#waiting_for_input = false
			#active_areas.push_back(current_pickup)
		#return
	
	if active_areas.size() > 0 and can_interact:
		active_areas.sort_custom(_sort_by_distance)
		current_pickup = active_areas[0]
		_update_ui(delta)
	else:
		_reset_pickup()

func _sort_by_distance(area1, area2):
	var dist_to_area1 = global_position.distance_to(area1.global_position)
	var dist_to_area2 = global_position.distance_to(area2.global_position)
	return dist_to_area1 < dist_to_area2

func register_area(area: InteractionComponent):
	#if area.need_input:
		## show UI but don’t start pickup timer yet
		#waiting_for_input = true
		#current_pickup = area
	#else:
		active_areas.push_back(area)

func unregister_area(area: InteractionComponent):
	_reset_pickup()
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
	#if current_pickup == area:
		#_reset_pickup()

func _update_ui(delta: float) -> void:
	if current_pickup == null:
		return
	if not current_pickup.can_interact:
		return
	# update label position + text
	label.text = current_pickup.interact_name
	label.global_position = current_pickup.global_position + Vector2(-label.size.x / 2, -60)
	label.show()

	# update pickup timer and progress bar
	pickup_timer += pickup_speed * delta
	interact_progress_bar.value = clamp((pickup_timer / current_pickup.interact_duration) * 100.0, 0, 100)
	interact_progress_bar.global_position = current_pickup.global_position + Vector2(-interact_progress_bar.size.x / 2, -10)
	interact_progress_bar.show()

	# trigger pickup when full
	if pickup_timer >= current_pickup.interact_duration:
		current_pickup.interact.call(get_parent())
		_reset_pickup()

func _reset_pickup() -> void:
	#waiting_for_input = false
	pickup_timer = 0.0
	current_pickup = null
	interact_progress_bar.value = 0
	interact_progress_bar.hide()
	label.hide()
