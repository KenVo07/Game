extends KinematicBody2D

# ==========================================
# PLAYER CONTROLLER
# ==========================================
# Twin-stick style movement and combat

# Movement
export var move_speed = 200.0
export var dodge_speed = 400.0
export var dodge_duration = 0.3
export var dodge_cooldown = 1.0

var velocity = Vector2.ZERO
var is_dodging = false
var dodge_time_remaining = 0.0
var dodge_cooldown_remaining = 0.0
var dodge_direction = Vector2.ZERO

# Combat
export var attack_damage = 10
export var attack_cooldown = 0.3
export var projectile_speed = 400.0

var attack_cooldown_remaining = 0.0
var can_shoot = true

# References
var projectile_scene = null  # Would load actual projectile scene

# Stats (synced with CultivationSystem)
var max_health = 100
var current_health = 100
var max_qi = 100
var current_qi = 100

# Signals
signal health_changed(current, max_value)
signal qi_changed(current, max_value)
signal player_died()

func _ready():
	# Sync with CultivationSystem
	sync_stats_from_cultivation()
	
	# Connect to cultivation system signals
	CultivationSystem.connect("stat_changed", self, "_on_stat_changed")
	CultivationSystem.connect("qi_changed", self, "_on_qi_changed")
	
	print("Player initialized")

func _process(delta):
	# Update cooldowns
	if dodge_cooldown_remaining > 0:
		dodge_cooldown_remaining -= delta
	
	if attack_cooldown_remaining > 0:
		attack_cooldown_remaining -= delta
		can_shoot = attack_cooldown_remaining <= 0
	
	# Update dodge state
	if is_dodging:
		dodge_time_remaining -= delta
		if dodge_time_remaining <= 0:
			is_dodging = false
	
	# Natural qi regeneration
	regenerate_qi(delta)

func _physics_process(delta):
	# Handle input and movement
	if not is_dodging:
		handle_movement_input()
		handle_combat_input()
	else:
		# Continue dodge movement
		velocity = dodge_direction * dodge_speed
	
	# Look at mouse
	look_at(get_global_mouse_position())
	
	# Apply movement
	velocity = move_and_slide(velocity)

# ==========================================
# MOVEMENT
# ==========================================

func handle_movement_input():
	"""
	Handle WASD movement input
	"""
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	input_vector = input_vector.normalized()
	velocity = input_vector * move_speed
	
	# Handle dodge
	if Input.is_action_just_pressed("dodge") and can_dodge():
		perform_dodge(input_vector if input_vector.length() > 0 else Vector2(1, 0))

func can_dodge() -> bool:
	"""
	Check if player can dodge
	"""
	if is_dodging or dodge_cooldown_remaining > 0:
		return false
	
	# Check if have enough qi
	var dodge_qi_cost = 10
	return current_qi >= dodge_qi_cost

func perform_dodge(direction: Vector2):
	"""
	Perform a dodge roll
	"""
	is_dodging = true
	dodge_time_remaining = dodge_duration
	dodge_cooldown_remaining = dodge_cooldown
	dodge_direction = direction.normalized()
	
	# Consume qi
	consume_qi(10)
	
	# Could add invulnerability frames here
	print("Dodge!")

# ==========================================
# COMBAT
# ==========================================

func handle_combat_input():
	"""
	Handle shooting/attack input (mouse click)
	"""
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	"""
	Fire a projectile towards mouse
	"""
	if not can_shoot:
		return
	
	var qi_cost = 5
	if not consume_qi(qi_cost):
		print("Not enough qi to shoot!")
		return
	
	can_shoot = false
	attack_cooldown_remaining = attack_cooldown
	
	# Calculate direction to mouse
	var direction = (get_global_mouse_position() - global_position).normalized()
	
	# Spawn projectile (simplified - would use actual scene)
	spawn_projectile(direction)
	
	print("Shoot!")

func spawn_projectile(direction: Vector2):
	"""
	Spawn a projectile (placeholder implementation)
	"""
	# In a real implementation, would instantiate projectile scene
	# For now, just print
	pass

func deal_damage_to_enemy(enemy, damage: int):
	"""
	Deal damage to an enemy
	"""
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)

# ==========================================
# HEALTH & QI MANAGEMENT
# ==========================================

func take_damage(damage: int):
	"""
	Take damage
	"""
	current_health -= damage
	current_health = max(0, current_health)
	
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		die()
	
	print("Player took ", damage, " damage. Health: ", current_health, "/", max_health)

func heal(amount: int):
	"""
	Heal player
	"""
	current_health += amount
	current_health = min(current_health, max_health)
	
	emit_signal("health_changed", current_health, max_health)

func consume_qi(amount: int) -> bool:
	"""
	Consume qi for abilities
	"""
	if current_qi >= amount:
		current_qi -= amount
		emit_signal("qi_changed", current_qi, max_qi)
		return true
	return false

func restore_qi(amount: int):
	"""
	Restore qi
	"""
	current_qi += amount
	current_qi = min(current_qi, max_qi)
	emit_signal("qi_changed", current_qi, max_qi)

func regenerate_qi(delta: float):
	"""
	Natural qi regeneration
	"""
	var regen_rate = 5.0  # qi per second
	
	# Check for qi regen bonuses from abilities
	if AbilitySystem.has_effect("qi_regen"):
		var bonus = AbilitySystem.get_total_effect("qi_regen")
		regen_rate *= (1.0 + bonus)
	
	restore_qi(int(regen_rate * delta))

# ==========================================
# STAT SYNCHRONIZATION
# ==========================================

func sync_stats_from_cultivation():
	"""
	Sync player stats from CultivationSystem
	"""
	max_health = CultivationSystem.get_stat("max_vitality")
	current_health = CultivationSystem.get_stat("vitality")
	max_qi = CultivationSystem.get_stat("max_qi")
	current_qi = CultivationSystem.get_stat("qi")
	
	# Apply ability bonuses
	apply_ability_modifiers()
	
	emit_signal("health_changed", current_health, max_health)
	emit_signal("qi_changed", current_qi, max_qi)

func apply_ability_modifiers():
	"""
	Apply stat modifiers from abilities
	"""
	# Dodge cooldown reduction
	if AbilitySystem.has_effect("dodge_cooldown"):
		var reduction = AbilitySystem.get_total_effect("dodge_cooldown")
		dodge_cooldown *= (1.0 + reduction)  # reduction is negative

func _on_stat_changed(stat_name: String, old_value, new_value):
	"""
	React to cultivation stat changes
	"""
	match stat_name:
		"max_vitality":
			max_health = new_value
			emit_signal("health_changed", current_health, max_health)
		"vitality":
			current_health = new_value
			emit_signal("health_changed", current_health, max_health)
		"max_qi":
			max_qi = new_value
			emit_signal("qi_changed", current_qi, max_qi)

func _on_qi_changed(current, max_value):
	"""
	React to qi changes from cultivation system
	"""
	current_qi = current
	max_qi = max_value
	emit_signal("qi_changed", current_qi, max_qi)

# ==========================================
# DEATH & RESPAWN
# ==========================================

func die():
	"""
	Handle player death
	"""
	print("Player died!")
	emit_signal("player_died")
	
	# Could trigger simulation here or game over
	# For now, respawn
	yield(get_tree().create_timer(2.0), "timeout")
	respawn()

func respawn():
	"""
	Respawn player
	"""
	current_health = max_health
	current_qi = max_qi
	
	# Reset position (would use spawn point)
	global_position = Vector2.ZERO
	
	emit_signal("health_changed", current_health, max_health)
	emit_signal("qi_changed", current_qi, max_qi)
	
	print("Player respawned")

# ==========================================
# SPECIAL ABILITIES
# ==========================================

func use_active_ability(ability_name: String):
	"""
	Use an active ability
	"""
	AbilitySystem.activate_ability(ability_name)

# ==========================================
# SAVE/LOAD
# ==========================================

func get_save_data() -> Dictionary:
	"""
	Get player save data
	"""
	return {
		"position": global_position,
		"current_health": current_health,
		"current_qi": current_qi
	}

func load_save_data(data: Dictionary):
	"""
	Load player save data
	"""
	if data.has("position"):
		global_position = data["position"]
	if data.has("current_health"):
		current_health = data["current_health"]
	if data.has("current_qi"):
		current_qi = data["current_qi"]
	
	sync_stats_from_cultivation()
