extends KinematicBody2D

# Player Controller - Twin-stick combat inspired by Soul Knight

signal health_changed(new_health, max_health)
signal died()

# Movement
export var move_speed = 200.0
export var dash_speed = 600.0
export var dash_duration = 0.2
export var dash_cooldown = 1.0

var velocity = Vector2.ZERO
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.ZERO

# Combat
export var max_health = 100
var current_health = 100

export var attack_damage = 10
export var attack_speed = 0.5
var attack_timer = 0.0

# Shooting
var projectile_scene = preload("res://scenes/Projectile.tscn") # Will create this
var can_shoot = true
var shoot_cooldown = 0.2
var shoot_timer = 0.0

# Abilities
var ability_cooldowns = {}
var ability_durations = {}

# References
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var collision_shape = $CollisionShape2D

# Invulnerability frames
var invulnerable = false
var invulnerable_duration = 0.5
var invulnerable_timer = 0.0

func _ready():
	current_health = max_health
	_sync_health_with_cultivation()
	
	# Connect to cultivation system
	CultivationSystem.connect("stats_changed", self, "_on_cultivation_stats_changed")

func _sync_health_with_cultivation():
	max_health = CultivationSystem.stats["vitality"]
	current_health = min(current_health, max_health)
	emit_signal("health_changed", current_health, max_health)

func _physics_process(delta):
	_handle_timers(delta)
	
	if not is_dashing:
		_handle_movement(delta)
		_handle_aim()
		_handle_shooting()
		_handle_abilities()
	else:
		_handle_dash(delta)
	
	# Apply movement
	velocity = move_and_slide(velocity)
	
	# Update animation
	_update_animation()

func _handle_timers(delta):
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	if shoot_timer > 0:
		shoot_timer -= delta
	
	if attack_timer > 0:
		attack_timer -= delta
	
	if invulnerable_timer > 0:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			invulnerable = false
			modulate.a = 1.0

func _handle_movement(delta):
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
	
	# Apply movement speed with ability modifiers
	var speed = move_speed
	velocity = input_vector * speed
	
	# Dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and input_vector.length() > 0:
		_start_dash(input_vector)

func _start_dash(direction: Vector2):
	is_dashing = true
	dash_direction = direction.normalized()
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	# Check for phase dash ability
	if AbilitySystem.has_ability("Phantom Form"):
		invulnerable = true
		modulate.a = 0.5
	
	AudioManager.play_sfx("dash")

func _handle_dash(delta):
	dash_timer -= delta
	
	if dash_timer <= 0:
		is_dashing = false
		velocity = Vector2.ZERO
	else:
		velocity = dash_direction * dash_speed

func _handle_aim():
	# Aim towards mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	# Flip sprite based on aim direction
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _handle_shooting():
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		_shoot()
		shoot_timer = shoot_cooldown

func _shoot():
	# Basic projectile attack
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	# Check if we can afford qi cost
	var qi_cost = 5
	if not CultivationSystem.consume_qi(qi_cost):
		return  # Not enough qi
	
	# Create projectile (simplified - scene needs to be created)
	# var projectile = projectile_scene.instance()
	# projectile.global_position = global_position
	# projectile.direction = direction
	# projectile.damage = attack_damage
	# get_parent().add_child(projectile)
	
	AudioManager.play_sfx("attack")

func _handle_abilities():
	# Ability 1
	if Input.is_action_just_pressed("ability1"):
		_use_ability(1)
	
	# Ability 2
	if Input.is_action_just_pressed("ability2"):
		_use_ability(2)

func _use_ability(slot: int):
	# Get available techniques from cultivation
	var techniques = CultivationSystem.get_available_techniques()
	
	if slot > techniques.size():
		return
	
	var technique = techniques[slot - 1]
	
	# Execute technique based on name
	match technique:
		"Thunder Strike":
			_thunder_strike()
		"Shadow Step":
			_shadow_step()
		"Fire Talisman":
			_fire_talisman()
		_:
			pass

func _thunder_strike():
	if not CultivationSystem.consume_qi(20):
		return
	
	# AOE damage around player
	# TODO: Implement actual damage area
	print("Thunder Strike!")
	AudioManager.play_sfx("ability_unlock")

func _shadow_step():
	if not CultivationSystem.consume_qi(15):
		return
	
	# Teleport to mouse position
	var mouse_pos = get_global_mouse_position()
	var max_distance = 200
	var direction = (mouse_pos - global_position).normalized()
	global_position += direction * max_distance
	
	invulnerable = true
	invulnerable_timer = 0.3

func _fire_talisman():
	if not CultivationSystem.consume_qi(10):
		return
	
	# Shoot fire projectile
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	# Apply talisman ability modifiers
	var talisman_damage = attack_damage * 2
	var qi_cost_mult = AbilitySystem.get_ability_effect("talisman_cost", 1.0)
	var damage_mult = AbilitySystem.get_ability_effect("talisman_damage", 1.0)
	
	talisman_damage *= damage_mult
	
	# Create fire projectile
	print("Fire Talisman! Damage: ", talisman_damage)

func _update_animation():
	if is_dashing:
		if animation_player and animation_player.has_animation("dash"):
			animation_player.play("dash")
	elif velocity.length() > 10:
		if animation_player and animation_player.has_animation("walk"):
			animation_player.play("walk")
	else:
		if animation_player and animation_player.has_animation("idle"):
			animation_player.play("idle")

func take_damage(amount: int, source = null):
	if invulnerable:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	
	emit_signal("health_changed", current_health, max_health)
	
	# Invulnerability frames
	invulnerable = true
	invulnerable_timer = invulnerable_duration
	modulate.a = 0.7
	
	if current_health <= 0:
		die()
	else:
		AudioManager.play_sfx("hit")

func heal(amount: int):
	current_health += amount
	current_health = min(current_health, max_health)
	emit_signal("health_changed", current_health, max_health)

func die():
	emit_signal("died")
	AudioManager.play_sfx("death")
	
	# Trigger death simulation or respawn
	# For now, just reset
	current_health = max_health
	StoryStateManager.modify_state("karma", -5, "Player died")

func _on_cultivation_stats_changed(stat_name, old_value, new_value):
	if stat_name == "vitality":
		_sync_health_with_cultivation()
