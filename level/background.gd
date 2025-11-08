extends CanvasLayer
class_name Background

var scrolling_speed := 1.0: set = update_scrolling_speed
@onready var background_texture: ColorRect = $BackgroundTexture
@onready var shader_material: ShaderMaterial = background_texture.material

func update_scrolling_speed(new_speed: float) -> void:
	scrolling_speed = new_speed
	if shader_material:
		shader_material.set_shader_parameter("speed", scrolling_speed)
