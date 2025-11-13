extends VBoxContainer
class_name Upgrades

var upgrades : Array[Upgrade] = []

func _ready() -> void:
	visibility_changed.connect(init_upgrades)
	var cs : Array[Node] = get_children()
	for c in cs:
		if c is Upgrade:
			upgrades.append(c)
			c.tree_exited.connect(func(): upgrades.erase(c))

func init_upgrades():
	if upgrades.size() == 0:
		return

	for upgrade in upgrades:
		upgrade.disabled = true
		upgrade.visible = false

	var available_upgrades = upgrades.filter(func(u):
		return not u.is_sold_out()
	)

	if available_upgrades.size() == 0:
		return

	available_upgrades.shuffle()
	var to_enable = available_upgrades.slice(0, min(5, available_upgrades.size()))

	for u in to_enable:
		u.disabled = false
		u.visible = true
