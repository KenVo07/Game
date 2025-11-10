extends KinematicBody2D

# ==========================================
# PLAYER CONTROLLER
# ==========================================
# Twin-stick style movement and combat

signal health_changed(new_health, max_health)
signal qi_changed(new_qi, max_qi)
signal player_died()

# Movement
export var move_speed = 200.0
export var dodge_speed = 400.0
export var dodge_duration = 0.2
export var dodge_cooldown = 1.0

var velocity = Vector2.ZERO
var is_dodging = false
var dodge_timer = 0.0
var dodge_cooldown_timer = 0.0

# Combat
export var projectile_speed = 400.0
export var fire_rate = 0.2
export var projectile_damage = 10

var can_shoot = true
var shoot_timer = 0.0
var aim_direction = Vector2.RIGHT

# Node references
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
onready var collision_shape = $CollisionShape2D

# Projectile scene (to be created)
var projectile_scene = preload("res://scenes/Projectile.tscn") if ResourceLoader.exists("res://scenes/Projectile.tscn") else null

func _ready():
	# Connect to cultivation system for stats
	CultivationSystem.connect("stat_changed", self, "_on_stat_changed")
	
	# Initialize health and qi from cultivation system
	emit_signal("health_changed", CultivationSystem.stats["health"], CultivationSystem.stats["health_max"])
	emit_signal("qi_changed", CultivationSystem.stats["qi"], CultivationSystem.stats["qi_max"])
	
	print("[Player] Initialized")

func _physics_process(delta):
	_update_timers(delta)
	_handle_movement(delta)
	_handle_shooting(delta)
	_handle_dodge(delta)

func _update_timers(delta):
	"""Update cooldown timers"""
	if shoot_timer > 0:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true
	
	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta
	
	if dodge_timer > 0:
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false

func _handle_movement(delta):
	"""Handle WASD movement"""
	if is_dodging:
		# Continue dodge movement
		velocity = move_and_slide(velocity, Vector2.UP)
		return
	
	var input_vector = Vector2.ZERO
	
	# Get input
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	
	# Normalize diagonal movement
	input_vector = input_vector.normalized()
	
	# Apply movement speed (modified by agility stat)
	var speed_multiplier = 1.0 + (CultivationSystem.stats["agility"] - 10) * 0.02
	velocity = input_vector * move_speed * speed_multiplier
	
	# Move
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Update sprite direction
	if input_vector.length() > 0:
		_update_sprite_direction(input_vector)

func _handle_shooting(delta):
	"""Handle arrow key shooting (twin-stick style)"""
	if is_dodging:
		return
	
	var shoot_input = Vector2.ZERO
	
	# Get shooting input
	if Input.is_action_pressed("shoot_right"):
		shoot_input.x += 1
	if Input.is_action_pressed("shoot_left"):
		shoot_input.x -= 1
	if Input.is_action_pressed("shoot_down"):
		shoot_input.y += 1
	if Input.is_action_pressed("shoot_up"):
		shoot_input.y -= 1
	
	if shoot_input.length() > 0:
		aim_direction = shoot_input.normalized()
		
		if can_shoot:
			_shoot()

func _shoot():
	"""Fire a projectile"""
	# Check qi cost
	var qi_cost = 5
	if CultivationSystem.stats["qi"] < qi_cost:
		print("[Player] Not enough qi to shoot")
		return
	
	# Consume qi
	CultivationSystem.modify_stat("qi", -qi_cost)
	emit_signal("qi_changed", CultivationSystem.stats["qi"], CultivationSystem.stats["qi_max"])
	
	# Create projectile
	if projectile_scene:
		var projectile = projectile_scene.instance()
		projectile.global_position = global_position
		projectile.direction = aim_direction
		projectile.speed = projectile_speed
		projectile.damage = projectile_damage + CultivationSystem.stats["strength"]
		get_parent().add_child(projectile)
	else:
		# Visual feedback even without projectile scene
		print("[Player] Shot projectile in direction: " + str(aim_direction))
	
	# Play sound effect
	AudioManager.play_sfx("qi_blast")
	
	# Set cooldown
	can_shoot = false
	shoot_timer = fire_rate
	
	# Update aim sprite direction
	_update_sprite_direction(aim_direction)

func _handle_dodge(delta):
	"""Handle dodge/dash (spacebar)"""
	if Input.is_action_just_pressed("dodge") and not is_dodging and dodge_cooldown_timer <= 0:
		_perform_dodge()

func _perform_dodge():
	"""Execute a dodge"""
	# Determine dodge direction (prefer movement input, fallback to aim direction)
	var dodge_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		dodge_direction.x += 1
	if Input.is_action_pressed("move_left"):
		dodge_direction.x -= 1
	if Input.is_action_pressed("move_down"):
		dodge_direction.y += 1
	if Input.is_action_pressed("move_up"):
		dodge_direction.y -= 1
	
	if dodge_direction.length() == 0:
		dodge_direction = aim_direction
	
	dodge_direction = dodge_direction.normalized()
	
	# Apply dodge
	is_dodging = true
	dodge_timer = dodge_duration
	dodge_cooldown_timer = dodge_cooldown
	velocity = dodge_direction * dodge_speed
	
	# During dodge, player is invulnerable (would be implemented with collision layers)
	set_collision_layer_bit(0, false)
	
	# Play dodge animation/sound
	AudioManager.play_sfx("dodge")
	
	# Re-enable collision after dodge
	yield(get_tree().create_timer(dodge_duration), "timeout")
	set_collision_layer_bit(0, true)
	
	print("[Player] Dodged!")

func _update_sprite_direction(direction: Vector2):
	"""Update sprite facing direction"""
	if sprite:
		# Flip sprite based on horizontal direction
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

func take_damage(damage: int, damage_type: String = "physical"):
	"""Player takes damage"""
	if is_dodging:
		return  # Invulnerable during dodge
	
	# Apply defense based on vitality
	var defense = CultivationSystem.stats["vitality"] * 0.5
	var actual_damage = max(1, damage - int(defense))
	
	CultivationSystem.take_damage(actual_damage)
	emit_signal("health_changed", CultivationSystem.stats["health"], CultivationSystem.stats["health_max"])
	
	print("[Player] Took %d damage" % actual_damage)
	
	# Check for death
	if CultivationSystem.stats["health"] <= 0:
		_die()

func _die():
	"""Handle player death"""
	print("[Player] Player died!")
	emit_signal("player_died")
	
	# Trigger simulation
	# This would open the simulation UI
	# For now, just print
	get_tree().call_deferred("change_scene", "res://scenes/SimulationScene.tscn")

func heal(amount: int):
	"""Heal the player"""
	CultivationSystem.heal(amount)
	emit_signal("health_changed", CultivationSystem.stats["health"], CultivationSystem.stats["health_max"])

func restore_qi(amount: int):
	"""Restore qi"""
	CultivationSystem.restore_qi(amount)
	emit_signal("qi_changed", CultivationSystem.stats["qi"], CultivationSystem.stats["qi_max"])

func _on_stat_changed(stat_name, old_value, new_value):
	"""React to stat changes from cultivation system"""
	match stat_name:
		"health", "health_max":
			emit_signal("health_changed", CultivationSystem.stats["health"], CultivationSystem.stats["health_max"])
		"qi", "qi_max":
			emit_signal("qi_changed", CultivationSystem.stats["qi"], CultivationSystem.stats["qi_max"])

func _process(delta):
	"""Handle UI and interaction input"""
	if Input.is_action_just_pressed("open_simulation"):
		_open_simulation_menu()
	
	if Input.is_action_just_pressed("open_menu"):
		_open_game_menu()
	
	# Natural qi regeneration
	if CultivationSystem.stats["qi"] < CultivationSystem.stats["qi_max"]:
		var regen_rate = 2.0 + (CultivationSystem.stats["spirit"] * 0.1)
		CultivationSystem.restore_qi(int(regen_rate * delta))
		emit_signal("qi_changed", CultivationSystem.stats["qi"], CultivationSystem.stats["qi_max"])

func _open_simulation_menu():
	"""Open the Villain Simulator menu"""
	print("[Player] Opening simulation menu...")
	# This would open the simulation UI
	# For now, trigger a simulation
	get_tree().paused = true
	# Would show UI here

func _open_game_menu():
	"""Open the game menu"""
	print("[Player] Opening game menu...")
	get_tree().paused = !get_tree().paused
