extends HBoxContainer

@onready var inventory : InventoryComponent = get_parent()
var slots : Array

func _ready() -> void:
	get_slots()
	inventory.inventory_changed.connect(_update_hotbar)
	_update_hotbar()

func get_slots():
	slots = get_children()
	#for slot : TextureRect in slots:
		#slot.pressed.connect(inventory.select_slot.bind(slot.get_index()))

func _update_hotbar():
	for i in range(slots.size()):
		var slot_btn: TextureRect = slots[i]
		var slot_data: InventorySlot = inventory.hotbar[i]

		if slot_data.is_empty():
			slot_btn.texture = null
			slot_btn.get_node("CountLabel").text = ""
		else:
			slot_btn.texture = slot_data.item.icon
			if slot_data.item.is_stackable:
				slot_btn.get_node("CountLabel").text = str(slot_data.count)
			else:
				slot_btn.get_node("CountLabel").text = ""

func _highlight_hotbar(slot_index : int):
	for i in range(slots.size()):
		slots[i].modulate = Color(1,1,1)
	slots[slot_index].modulate = Color(1.5,1.5,1.5)
