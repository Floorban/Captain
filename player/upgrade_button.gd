extends Button
class_name Upgrade

func _ready() -> void:
	pressed.connect(buy_upgrade)

func buy_upgrade():
	print("1")
