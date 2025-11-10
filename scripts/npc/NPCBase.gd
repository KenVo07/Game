extends KinematicBody2D

# ==========================================
# NPC BASE CLASS
# ==========================================
# Base class for all NPCs with reactive behavior

# NPC identity
export var npc_name = "Unknown NPC"
export var npc_type = "neutral"  # neutral, friendly, hostile, sect_member
export var sect_affiliation = ""

# Stats
export var max_health = 50
var current_health = 50
export var move_speed = 100.0
export var detection_range = 300.0
export var attack_range = 50.0

# Behavior
var behavior_state = "idle"  # idle, patrol, follow, combat, flee, dialogue
var target = null
var patrol_points = []
var current_patrol_index = 0

# Reputation tracking
var player_reputation = 0  # NPC's personal view of player
var initial_disposition = 0  # Starting disposition

# Dialogue
var dialogue_tree = {}
var current_dialogue_state = ""

# Signals
signal health_changed(current, max_value)
signal npc_died()
signal dialogue_started(npc)
signal dialogue_ended(npc)

func _ready():
	update_behavior_based_on_world_state()
	
	# Connect to world state changes
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")

func _process(delta):
	update_behavior(delta)

func _physics_process(delta):
	execute_behavior(delta)

# ==========================================
# BEHAVIOR SYSTEM
# ==========================================

func update_behavior_based_on_world_state():
	"""
	Update NPC behavior based on world state
	"""
	var karma = StoryStateManager.get_state("karma")
	var reputation = StoryStateManager.get_state("reputation")
	
	# Calculate effective reputation
	player_reputation = reputation + initial_disposition
	
	# Sect members react to sect influence
	if sect_affiliation != "":
		var sect_influence = StoryStateManager.get_sect_influence(sect_affiliation)
		player_reputation += sect_influence / 2
	
	# Karma affects neutral NPCs
	if npc_type == "neutral":
		player_reputation += karma / 4
	
	# Check if NPC is in enemies list
	if sect_affiliation in StoryStateManager.get_state("enemies"):
		behavior_state = "combat"
		npc_type = "hostile"
	elif sect_affiliation in StoryStateManager.get_state("alliances"):
		npc_type = "friendly"

func update_behavior(delta):
	"""
	Update behavior state based on surroundings
	"""
	var player = get_player()
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	match behavior_state:
		"idle":
			if distance_to_player < detection_range:
				detect_player(player, distance_to_player)
		
		"patrol":
			if distance_to_player < detection_range:
				detect_player(player, distance_to_player)
		
		"combat":
			if not target or not is_instance_valid(target):
				behavior_state = "idle"
			elif target.global_position.distance_to(global_position) > detection_range * 2:
				behavior_state = "idle"
				target = null
		
		"follow":
			if distance_to_player > detection_range * 2:
				behavior_state = "idle"

func detect_player(player, distance: float):
	"""
	React to detecting the player
	"""
	if npc_type == "hostile" or player_reputation < -30:
		behavior_state = "combat"
		target = player
	elif npc_type == "friendly" or player_reputation > 30:
		behavior_state = "follow"
		target = player
	elif distance < 100:
		# Close enough for dialogue
		pass

func execute_behavior(delta):
	"""
	Execute current behavior
	"""
	match behavior_state:
		"idle":
			pass  # Stand still
		
		"patrol":
			execute_patrol(delta)
		
		"combat":
			execute_combat(delta)
		
		"follow":
			execute_follow(delta)
		
		"flee":
			execute_flee(delta)

func execute_patrol(delta):
	"""
	Patrol between points
	"""
	if patrol_points.size() == 0:
		behavior_state = "idle"
		return
	
	var target_point = patrol_points[current_patrol_index]
	var direction = (target_point - global_position).normalized()
	var velocity = direction * move_speed
	
	move_and_slide(velocity)
	
	if global_position.distance_to(target_point) < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func execute_combat(delta):
	"""
	Combat behavior
	"""
	if not target or not is_instance_valid(target):
		behavior_state = "idle"
		return
	
	var distance = global_position.distance_to(target.global_position)
	
	if distance > attack_range:
		# Move towards target
		var direction = (target.global_position - global_position).normalized()
		var velocity = direction * move_speed
		move_and_slide(velocity)
		
		# Look at target
		look_at(target.global_position)
	else:
		# Attack
		attack_target()

func execute_follow(delta):
	"""
	Follow player
	"""
	if not target or not is_instance_valid(target):
		behavior_state = "idle"
		return
	
	var distance = global_position.distance_to(target.global_position)
	var follow_distance = 80.0
	
	if distance > follow_distance:
		var direction = (target.global_position - global_position).normalized()
		var velocity = direction * move_speed
		move_and_slide(velocity)

func execute_flee(delta):
	"""
	Flee from player
	"""
	var player = get_player()
	if not player:
		behavior_state = "idle"
		return
	
	var direction = (global_position - player.global_position).normalized()
	var velocity = direction * move_speed * 1.2
	move_and_slide(velocity)

# ==========================================
# COMBAT
# ==========================================

func attack_target():
	"""
	Attack the current target
	"""
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage(10)  # Base damage

func take_damage(damage: int):
	"""
	Take damage
	"""
	current_health -= damage
	current_health = max(0, current_health)
	
	emit_signal("health_changed", current_health, max_health)
	
	# React to damage
	if behavior_state != "combat":
		var attacker = get_last_attacker()  # Would track this
		if attacker:
			behavior_state = "combat"
			target = attacker
	
	if current_health <= 0:
		die()

func die():
	"""
	NPC death
	"""
	emit_signal("npc_died")
	
	# Drop rewards
	drop_loot()
	
	# World state changes
	if sect_affiliation != "":
		StoryStateManager.modify_sect_influence(sect_affiliation, -5)
	
	# Queue for removal
	queue_free()

func drop_loot():
	"""
	Drop loot on death
	"""
	# Placeholder - would spawn loot items
	pass

# ==========================================
# DIALOGUE
# ==========================================

func start_dialogue():
	"""
	Start dialogue with player
	"""
	emit_signal("dialogue_started", self)
	behavior_state = "dialogue"

func get_dialogue_options() -> Array:
	"""
	Get available dialogue options based on world state
	"""
	var options = []
	
	# Basic greeting based on reputation
	if player_reputation > 50:
		options.append({
			"text": "Greetings, honored cultivator!",
			"response": "dialogue_friendly"
		})
	elif player_reputation < -50:
		options.append({
			"text": "You... how dare you show your face here!",
			"response": "dialogue_hostile"
		})
	else:
		options.append({
			"text": "What do you want?",
			"response": "dialogue_neutral"
		})
	
	# Quest-specific options
	if has_quest():
		options.append({
			"text": "I have a task for you...",
			"response": "dialogue_quest"
		})
	
	# Sect-specific dialogue
	if sect_affiliation != "":
		options.append({
			"text": "About the " + sect_affiliation + "...",
			"response": "dialogue_sect"
		})
	
	return options

func respond_to_dialogue(choice: String) -> Dictionary:
	"""
	Respond to player's dialogue choice
	"""
	var response = {
		"text": "",
		"effects": {}
	}
	
	match choice:
		"dialogue_friendly":
			response["text"] = "It's good to see a righteous cultivator in these dark times."
		"dialogue_hostile":
			response["text"] = "Your reputation precedes you, villain!"
			response["effects"]["start_combat"] = true
		"dialogue_neutral":
			response["text"] = "The world grows stranger each day..."
		"dialogue_quest":
			response["text"] = "If you help me, I will reward you."
			response["effects"]["start_quest"] = true
		"dialogue_sect":
			response["text"] = "Our sect has noticed your actions."
	
	return response

func end_dialogue():
	"""
	End dialogue
	"""
	emit_signal("dialogue_ended", self)
	behavior_state = "idle"

func has_quest() -> bool:
	"""
	Check if NPC has a quest
	"""
	return false  # Placeholder

# ==========================================
# UTILITY
# ==========================================

func get_player():
	"""
	Get reference to player node
	"""
	return get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null

func get_last_attacker():
	"""
	Get last entity that attacked this NPC
	"""
	# Placeholder - would track this
	return get_player()

func _on_world_state_changed(variable_name: String, old_value, new_value):
	"""
	React to world state changes
	"""
	if variable_name in ["karma", "reputation"] or variable_name.begins_with("sect_influence"):
		update_behavior_based_on_world_state()
