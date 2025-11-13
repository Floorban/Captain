extends MarginContainer

@onready var loading_bar: ProgressBar = $Panel/LoadingBar
var has_started := false

func _ready() -> void:
	visibility_changed.connect(_loading_screen)

func _physics_process(delta: float) -> void:
	if has_started:
		Audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MOVING)
		Global.radar_controller.monitor.trauma = 0.15
		loading_bar.value += delta * 50.0
		if loading_bar.value == loading_bar.max_value:
			Global.game_controller.set_game_content()
			has_started = false
	else:
		loading_bar.value = 0.0
		Audio.stop_audio_by_type(SoundEffect.SOUND_EFFECT_TYPE.MOVING)

func _loading_screen():
	if has_started: 
		has_started = false
		return
	has_started = true
