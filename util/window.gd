extends Window
class_name Wwindow

@export var x := 0
@export var y := 400

@export var width_range: Vector2i = Vector2i(100, 1000)
@export var height_range: Vector2i = Vector2i(100, 1000)

func _ready() -> void:
	position.x = x
	position.y = y

func random_size() -> Vector2i:
	return Vector2(randi_range(width_range.x, width_range.y), randi_range(height_range.x, height_range.y))

func init_window(_x: float, _y: float):
	position.x = int(_x)
	position.y = int(_y)
	size = random_size()
