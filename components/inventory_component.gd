extends Control
class_name InventoryComponent

signal inventory_changed
signal item_delivered(item: ItemData, count: int)

var hotbar_size := 3
var hotbar : Array[InventorySlot]

func _init() -> void:
	hotbar.resize(hotbar_size)
	for i in range(hotbar_size):
		hotbar[i] = InventorySlot.new()

func add_item(item: ItemData, amount: int = 1) -> bool:
	# try stack first
	for i in range(hotbar_size):
		var slot = hotbar[i]
		if slot.can_stack(item):
			var space_left = slot.item.max_stack - slot.count
			var to_add = min(space_left, amount)
			slot.count += to_add
			amount -= to_add
			inventory_changed.emit()
			if amount <= 0:
				return true

	# try put in empty slots
	for i in range(hotbar_size):
		var slot = hotbar[i]
		if slot.is_empty():
			slot.item = item
			slot.count = min(amount, item.max_stack if item.is_stackable else 1)
			amount -= slot.count
			inventory_changed.emit()
			if amount <= 0:
				return true

	print("Inventory full — couldn't add", amount, item.item_name)
	return false

func deliver_inventory():
	for slot in hotbar:
		if not slot.is_empty():
			print("Delivered:", slot.item.item_name, "x", slot.count)
			item_delivered.emit(slot.item, slot.count)
			slot.clear()
	inventory_changed.emit()
