extends Resource
class_name ItemData

enum ITEM_TYPE {
	FUEL,
	HEAL,
	SHIELD
}

@export var item_name: String = "Default Item"
@export var icon : Texture2D
@export var item_type: ITEM_TYPE = ITEM_TYPE.FUEL
@export var value: float = 10.0 

@export var is_stackable := true
@export var max_stack: int = 1
@export var description: String = ""
