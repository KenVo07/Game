extends KinematicBody2D

# ==========================================
# ENEMY BASE CLASS
# ==========================================
# Basic enemy with AI behavior

export var health = 50
export var max_health = 50
export var move_speed = 100.0
export var damage = 10
export var aggro_range = 300.0
export var attack_range = 50.0
export var attack_cooldown = 1.5

var velocity = Vector2.ZERO
var player = null
var can_attack = true
var attack_timer = 0.0

enum State {
	IDLE,
	CHASE,
	ATTACK,
	DEAD
}

var current_state = State.IDLE

onready var sprite = $Sprite if has_node("Sprite") else null

func _ready():
	# Find player
	yield(get_tree(), "idle_frame")
	player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null

func _physics_process(delta):
	if current_state == State.DEAD:
		return
	
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
	
	_update_ai(delta)

func _update_ai(delta):
	"""Update enemy AI behavior"""
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	match current_state:
		State.IDLE:
			if distance_to_player < aggro_range:
				current_state = State.CHASE
		
		State.CHASE:
			if distance_to_player > aggro_range * 1.5:
				current_state = State.IDLE
			elif distance_to_player < attack_range:
				current_state = State.ATTACK
			else:
				_move_toward_player(delta)
		
		State.ATTACK:
			if distance_to_player > attack_range * 1.2:
				current_state = State.CHASE
			else:
				_attack_player()

func _move_toward_player(delta):
	"""Move toward player"""
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed
	velocity = move_and_slide(velocity)
	
	# Update sprite direction
	if sprite and direction.x != 0:
		sprite.flip_h = direction.x < 0

func _attack_player():
	"""Attack player"""
	if can_attack and player:
		player.take_damage(damage)
		can_attack = false
		attack_timer = attack_cooldown
		print("[Enemy] Attacked player for %d damage" % damage)

func take_damage(amount: int):
	"""Enemy takes damage"""
	health -= amount
	print("[Enemy] Took %d damage (%d/%d HP)" % [amount, health, max_health])
	
	# Visual feedback would go here (flash red, etc.)
	
	if health <= 0:
		_die()

func _die():
	"""Enemy dies"""
	current_state = State.DEAD
	print("[Enemy] Enemy defeated")
	
	# Drop loot, grant experience, etc.
	_drop_loot()
	
	# Remove from scene
	queue_free()

func _drop_loot():
	"""Drop items or rewards"""
	# Chance to drop spirit stones, pills, etc.
	var drop_chance = randf()
	if drop_chance < 0.3:
		# 30% chance to drop something
		var drops = ["Spirit Stone", "Qi Pill", "Talisman Paper"]
		var item = drops[randi() % drops.size()]
		StoryStateManager.modify_state("inventory", item)
		print("[Enemy] Dropped: " + item)
