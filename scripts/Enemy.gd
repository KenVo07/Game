extends KinematicBody2D

# Enemy - Basic hostile NPC with AI

export var enemy_name = "Demonic Beast"
export var max_health = 50
export var damage = 10
export var move_speed = 100.0
export var detection_range = 300.0
export var attack_range = 50.0
export var experience_reward = 10

var current_health = 50
var velocity = Vector2.ZERO
var target = null
var state = "idle"  # idle, chase, attack, dead

onready var sprite = $Sprite
onready var detection_area = $DetectionArea
onready var attack_timer = $AttackTimer

func _ready():
	current_health = max_health
	add_to_group("enemies")
	
	if detection_area:
		detection_area.connect("body_entered", self, "_on_detection_area_entered")
		detection_area.connect("body_exited", self, "_on_detection_area_exited")
	
	if attack_timer:
		attack_timer.wait_time = 1.0
		attack_timer.connect("timeout", self, "_on_attack_timer_timeout")

func _physics_process(delta):
	match state:
		"idle":
			_idle_behavior(delta)
		"chase":
			_chase_behavior(delta)
		"attack":
			_attack_behavior(delta)
		"dead":
			return

func _idle_behavior(_delta):
	velocity = Vector2.ZERO

func _chase_behavior(_delta):
	if not is_instance_valid(target):
		state = "idle"
		return
	
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * move_speed
	
	# Check if in attack range
	var distance = global_position.distance_to(target.global_position)
	if distance <= attack_range:
		state = "attack"
		attack_timer.start()
	
	velocity = move_and_slide(velocity)

func _attack_behavior(_delta):
	if not is_instance_valid(target):
		state = "idle"
		return
	
	# Stop moving during attack
	velocity = Vector2.ZERO
	
	# Check if still in range
	var distance = global_position.distance_to(target.global_position)
	if distance > attack_range * 1.5:
		state = "chase"
		attack_timer.stop()

func _on_attack_timer_timeout():
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage, self)

func _on_detection_area_entered(body):
	if body.is_in_group("player") and state != "dead":
		target = body
		state = "chase"

func _on_detection_area_exited(body):
	if body == target:
		target = null
		state = "idle"
		attack_timer.stop()

func take_damage(amount: int, source = null):
	current_health -= amount
	current_health = max(0, current_health)
	
	# Aggro on source
	if source and source.is_in_group("player"):
		target = source
		state = "chase"
	
	if current_health <= 0:
		die()
	else:
		# Damage flash
		modulate = Color(1.5, 0.5, 0.5)
		yield(get_tree().create_timer(0.1), "timeout")
		modulate = Color.white

func die():
	state = "dead"
	
	# Grant rewards to player
	_grant_rewards()
	
	# Play death animation
	modulate.a = 0.5
	
	# Clean up after animation
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()

func _grant_rewards():
	# Grant cultivation experience
	var stat_gain = max(1, experience_reward / 10)
	CultivationSystem.modify_stat("strength", randi() % stat_gain + 1)
	CultivationSystem.modify_stat("spirit", randi() % stat_gain + 1)
	
	# Small karma penalty for killing (depending on enemy type)
	if "Righteous" in enemy_name or "Disciple" in enemy_name:
		StoryStateManager.modify_state("karma", -3, "Killed righteous cultivator")
	elif "Demon" in enemy_name or "Beast" in enemy_name:
		StoryStateManager.modify_state("karma", 1, "Slew demonic creature")
	
	# Check for Echo of the Dead ability
	if AbilitySystem.has_ability("Echo of the Dead"):
		CultivationSystem.modify_stat("comprehension", 1)
