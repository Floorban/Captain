extends TextureRect
class_name SelectMarker

@onready var label_name: Label = $VBoxContainer/LabelName
@onready var label_x: Label = $VBoxContainer/LabelX
@onready var label_y: Label = $VBoxContainer/LabelY

func no_result(x,y):
	if Global.is_dead: return
	show()
	label_name.text = "???"
	label_name.modulate = Color.WHITE
	label_x.text = x
	label_y.text = y
	label_name.show()
	label_x.show()
	label_y.show()

func set_label_text(n,x,y,c):
	if Global.is_dead: return
	show()
	label_name.text = n
	label_name.modulate = c
	label_x.text = x
	label_y.text = y
	label_name.show()
	label_x.show()
	label_y.show()

func hide_labels():
	hide()
	label_name.hide()
	label_x.hide()
	label_y.hide()
