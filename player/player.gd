extends CharacterBody2D
class_name Player

## --- Controls ---
@export var input_left := "left1"
@export var input_right := "right1"
@export var input_up := "up1"
@export var input_down := "down1"

## --- Attributes ---
var is_dead: bool = false
var can_control: bool = true
var can_move: bool = true
@export var is_captain: bool = false
@export var move_speed: float = 100.0
@export var friction: float = 0.99

@export var rotation_threshold: float = 0.1
@export var rotation_smoothness: float = 8.0

## --- Damage Effect ---
@onready var health_component: HealthComponent = %HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@export var hp_bar : HealthBar
@onready var shield_sprite: Sprite2D = $ShieldSprite
var is_stunned: bool = false
var stun_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

## --- Interaction ---
@onready var interaction_controller : InteractionController = $InteractionController
@export var interaction : InteractionComponent
@export var inventory : InventoryComponent
@onready var detection_area: DetectionArea = %DetectionArea

func _ready() -> void:
	_init_player_signals()
	if is_captain and interaction != null:
		interaction.interact = Callable(self, "_receive_items")
	if shield_sprite:
		shield_sprite.hide()

func _init_player_signals():
	health_component.died.connect(_on_player_dead)
	if is_captain:
		hitbox_component.hit.connect(dmg_effect)
	if hp_bar: 
		health_component.health_bar = hp_bar
		health_component.health_bar.health_component = health_component
		health_component.init_hp()
	hitbox_component.turn_invulnerable.connect(_toggle_player_shield)

func dmg_effect():
	Global.main.mini_map.play_dmg_effect()
	Global.radar_controller.move_interrupted()

func _on_player_dead():
	## explode particle here
	Global.radar_controller.remove_ship_radar_obj(self)

func _toggle_player_shield(has_shield: bool):
	if not shield_sprite:
		return
	if has_shield:
		shield_sprite.show()
	else:
		shield_sprite.hide()

func _physics_process(delta: float) -> void:
	_process_knockback(delta)
	_process_movement(delta)
	_process_rotation(delta)

## --- Input ---
func _get_move_input() -> Vector2:
	if is_dead or not can_control or is_captain: 
		return Vector2.ZERO
	var h_dir := Input.get_axis(input_left, input_right)
	var v_dir := Input.get_axis(input_up, input_down)
	return Vector2(h_dir, v_dir).normalized()

func _process_movement(delta: float) -> void:
	if is_captain or is_stunned or not can_move:
		velocity = knockback_velocity
		velocity *= friction
		move_and_slide()
		return

	var move_input := _get_move_input()

	if not is_captain:
		velocity = move_input * move_speed
	else:
		# captain moves horizontally only
		velocity.x = move_input.x * move_speed
		velocity.y = move_toward(velocity.y, 0, move_speed * delta)
		
	velocity *= friction
	move_and_slide()

func _process_rotation(delta: float) -> void:
	if is_captain or is_stunned: return
	if _get_move_input().length() > rotation_threshold:
		var target_angle := velocity.angle() + deg_to_rad(90)
		rotation = lerp_angle(rotation, target_angle, rotation_smoothness * delta)

func _process_knockback(delta: float):
	if is_captain or not is_stunned: return
	stun_timer -= delta
	if stun_timer <= 0.0:
		is_stunned = false
		knockback_velocity = Vector2.ZERO

func apply_knockback(direction: Vector2, strength: float, duration: float) -> void:
	if is_captain: return
	is_stunned = true
	stun_timer = duration
	knockback_velocity = direction.normalized() * strength

func _receive_items(interactor: Node):
	if interactor is Player and interactor.inventory != null:
		var inv = interactor.inventory as InventoryComponent
		inv.item_delivered.connect(_on_item_delivered)
		inv.deliver_inventory()
		inv.item_delivered.disconnect(_on_item_delivered)
	if interactor != self and interactor is Player:
		Global.radar_controller.remove_ship_radar_obj(interactor)

func _on_item_delivered(item: ItemData, count: int):
	print("Captain received:", item.item_name, "x", count)
	match item.item_type:
		item.ITEM_TYPE.FUEL:
			Global.add_fuel(item.value * count)
		item.ITEM_TYPE.HEAL:
			Global.add_health(item.value * count)
		item.ITEM_TYPE.SHIELD:
			Global.add_shield(item.value * count)
		item.ITEM_TYPE.SALVAGE:
			Global.add_load(item.weight * count)
	Global.update_stats()
