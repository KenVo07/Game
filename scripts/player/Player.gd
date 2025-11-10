extends KinematicBody2D

# ==========================================
# PLAYER CONTROLLER
# Twin-stick shooter style movement and combat
# ==========================================

signal health_changed(current_health, max_health)
signal qi_changed(current_qi, max_qi)
signal player_died()

# Movement
export var move_speed: float = 300.0
export var dodge_speed: float = 600.0
export var dodge_duration: float = 0.3

var velocity: Vector2 = Vector2.ZERO
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_direction: Vector2 = Vector2.ZERO

# Combat
var max_health: float = 100.0
var current_health: float = 100.0
var is_invincible: bool = false
var invincibility_timer: float = 0.0

# Attack
var can_attack: bool = true
var attack_cooldown: float = 0.5
var attack_timer: float = 0.0

# References
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
onready var attack_point = $AttackPoint if has_node("AttackPoint") else null

# Attack scenes (preload attack/projectile scenes)
var basic_projectile_scene = null  # Would be preload("res://scenes/projectiles/BasicProjectile.tscn")


func _ready():
	print("[Player] Initialized")
	_sync_with_cultivation_system()
	_connect_signals()


func _sync_with_cultivation_system():
	"""Sync player stats with cultivation system"""
	max_health = CultivationSystem.get_stat("vitality") * 10
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)


func _connect_signals():
	"""Connect to cultivation system updates"""
	CultivationSystem.connect("stat_increased", self, "_on_stat_increased")
	CultivationSystem.connect("realm_breakthrough", self, "_on_realm_breakthrough")


# ==========================================
# INPUT & MOVEMENT
# ==========================================

func _physics_process(delta):
	_handle_timers(delta)
	
	if is_dodging:
		_process_dodge(delta)
	else:
		_process_movement(delta)
	
	_process_combat(delta)
	_update_facing_direction()


func _process_movement(delta):
	"""Handle WASD movement"""
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	input_vector = input_vector.normalized()
	
	# Apply movement
	if input_vector.length() > 0:
		velocity = input_vector * move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta * 5)
	
	velocity = move_and_slide(velocity)
	
	# Handle dodge
	if Input.is_action_just_pressed("dodge") and not is_dodging:
		_start_dodge(input_vector)


func _start_dodge(direction: Vector2):
	"""Initiate dodge roll"""
	if direction.length() == 0:
		# Dodge in facing direction if no input
		direction = Vector2.RIGHT.rotated(rotation)
	
	is_dodging = true
	dodge_timer = dodge_duration
	dodge_direction = direction.normalized()
	is_invincible = true
	
	print("[Player] Dodge!")


func _process_dodge(delta):
	"""Handle dodge movement"""
	velocity = dodge_direction * dodge_speed
	velocity = move_and_slide(velocity)
	
	dodge_timer -= delta
	
	if dodge_timer <= 0:
		is_dodging = false
		is_invincible = false


# ==========================================
# COMBAT
# ==========================================

func _process_combat(delta):
	"""Handle attack input"""
	if Input.is_action_pressed("attack") and can_attack:
		_perform_attack()


func _perform_attack():
	"""Execute basic attack"""
	can_attack = false
	attack_timer = attack_cooldown
	
	# Get mouse position for aiming
	var mouse_pos = get_global_mouse_position()
	var attack_direction = (mouse_pos - global_position).normalized()
	
	# Consume qi
	var qi_cost = 10.0
	if not CultivationSystem.consume_qi(qi_cost):
		print("[Player] Not enough qi to attack")
		can_attack = true
		return
	
	# Create projectile or melee attack
	_spawn_projectile(attack_direction)
	
	# Play animation
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")
	
	# Play sound
	AudioManager.play_sfx("talisman_cast", 0.1)
	
	print("[Player] Attack!")


func _spawn_projectile(direction: Vector2):
	"""Spawn attack projectile"""
	# TODO: Implement actual projectile spawning
	# This would create a projectile scene and add it to the world
	print("[Player] Spawning projectile in direction: " + str(direction))


# ==========================================
# DAMAGE & HEALTH
# ==========================================

func take_damage(amount: float, source = null):
	"""Take damage from enemy or hazard"""
	if is_invincible or is_dodging:
		return
	
	# Apply damage reduction based on cultivation stats
	var vitality = CultivationSystem.get_stat("vitality")
	var damage_reduction = vitality * 0.01  # 1% per vitality
	var actual_damage = amount * (1.0 - damage_reduction)
	
	current_health -= actual_damage
	current_health = max(0, current_health)
	
	emit_signal("health_changed", current_health, max_health)
	
	# Brief invincibility after taking damage
	is_invincible = true
	invincibility_timer = 0.5
	
	# Play hurt animation/sound
	if animation_player and animation_player.has_animation("hurt"):
		animation_player.play("hurt")
	
	print("[Player] Took %.1f damage. Health: %.1f/%.1f" % [actual_damage, current_health, max_health])
	
	# Check for death
	if current_health <= 0:
		_player_death()


func heal(amount: float):
	"""Heal player"""
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health, max_health)


func _player_death():
	"""Handle player death"""
	print("[Player] Player has died!")
	emit_signal("player_died")
	
	# Play death animation
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")
	
	# Play death sound
	AudioManager.play_sfx("death")
	
	# Check for Eternal Regression ability
	if AbilitySystem.has_death_immunity():
		print("[Player] Eternal Regression activated - death prevented!")
		current_health = max_health * 0.5
		global_position = Vector2.ZERO  # Respawn at checkpoint
		return
	
	# Otherwise, trigger game over
	get_tree().call_group("game_manager", "on_player_death")


# ==========================================
# UTILITY
# ==========================================

func _update_facing_direction():
	"""Update sprite facing based on mouse position"""
	var mouse_pos = get_global_mouse_position()
	
	# Flip sprite based on mouse position
	if sprite:
		if mouse_pos.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false


func _handle_timers(delta):
	"""Update cooldown timers"""
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
	
	if is_invincible and not is_dodging:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false


# ==========================================
# CULTIVATION INTEGRATION
# ==========================================

func _on_stat_increased(stat_name: String, new_value):
	"""React to stat increases"""
	if stat_name == "vitality":
		var old_max = max_health
		max_health = new_value * 10
		# Maintain health percentage
		var health_percent = current_health / old_max if old_max > 0 else 1.0
		current_health = max_health * health_percent
		emit_signal("health_changed", current_health, max_health)


func _on_realm_breakthrough(old_realm: String, new_realm: String):
	"""React to cultivation breakthrough"""
	print("[Player] Realm breakthrough: %s -> %s" % [old_realm, new_realm])
	
	# Full heal on breakthrough
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	
	# Visual effect
	AudioManager.play_sfx("cultivation_breakthrough")


# ==========================================
# SAVE/LOAD
# ==========================================

func get_save_data() -> Dictionary:
	"""Return player data for saving"""
	return {
		"position": global_position,
		"health": current_health,
		"max_health": max_health
	}


func load_save_data(data: Dictionary):
	"""Restore player from save data"""
	if data.has("position"):
		global_position = data["position"]
	if data.has("health"):
		current_health = data["health"]
	if data.has("max_health"):
		max_health = data["max_health"]
	
	emit_signal("health_changed", current_health, max_health)


# ==========================================
# DEBUG
# ==========================================

func _input(event):
	"""Debug input handling"""
	if OS.is_debug_build():
		if event.is_action_pressed("ui_page_up"):
			heal(50)
		if event.is_action_pressed("ui_page_down"):
			take_damage(20)
