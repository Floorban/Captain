extends CharacterBody2D
class_name Pickup

@export var item_data: ItemData
@export var quantity: int = 1

@onready var interaction: InteractionComponent = $InteractionComponent
@onready var sprite: Sprite2D = $Sprite2D

@export var can_anim := true
var texture: AtlasTexture
var frame: int = 0
@export var frame_count: int = 12
@export var frame_speed: float = 10.0
var frame_timer: float = 0.0

func init_sprite():
	if item_data:
		sprite.texture = item_data.icon

func _ready() -> void:
	interaction.interact = Callable(self, "_on_pickup")
	interaction.interact_name = item_data.item_name
	init_sprite()
	var t := sprite.texture as AtlasTexture
	if t != null:
		texture = t

#func _physics_process(delta: float) -> void:
	#_anim_sprite(delta)

func _on_pickup(interactor: Node) -> void:
	if item_data.item_type == ItemData.ITEM_TYPE.SHIELD:
		if interactor.has_node("HitboxComponent"):
			var hb = interactor.get_node("HitboxComponent") as HitboxComponent
			if hb.is_invulnerable == false:
				hb.is_invulnerable = true
				call_deferred("queue_free")
			return
	
	if item_data.item_type == ItemData.ITEM_TYPE.HEAL:
		if interactor.has_node("HealthComponent"):
			var hl = interactor.get_node("HealthComponent") as HealthComponent
			if hl.cur_hp < hl.max_hp:
				hl.cur_hp += item_data.value
				call_deferred("queue_free")
				return
		
	if interactor is Player and interactor.inventory != null:
		var inv = interactor.inventory as InventoryComponent
		if inv.add_item(item_data, quantity):
			call_deferred("queue_free")
	

func _anim_sprite(delta: float):
	if texture == null or not can_anim:
		return

	frame_timer += delta
	if frame_timer >= 1.0 / frame_speed:
		frame_timer = 0.0
		frame = (frame + 1) % frame_count

		var region := texture.region
		region.position.x = frame * region.size.x
		texture.region = region
		sprite.texture = texture
