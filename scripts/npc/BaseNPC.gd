extends KinematicBody2D
class_name BaseNPC

# ==========================================
# BASE NPC CLASS
# Foundation for all NPCs with dialogue and reputation systems
# ==========================================

signal dialogue_started(npc_name)
signal dialogue_ended()
signal relationship_changed(npc_name, new_value)

# NPC Identity
export var npc_name: String = "Unknown NPC"
export var npc_title: String = "Wandering Cultivator"
export var affiliated_sect: String = ""

# Relationship
var relationship_value: int = 0  # -100 to 100
var is_hostile: bool = false
var is_ally: bool = false

# Dialogue
var dialogue_lines: Array = []
var current_dialogue_index: int = 0
var can_talk: bool = true

# Movement
export var wander_enabled: bool = true
export var wander_speed: float = 50.0
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

# References
onready var sprite = $Sprite
onready var interaction_area = $InteractionArea


func _ready():
	add_to_group("npcs")
	_initialize_dialogue()
	_update_npc_behavior()


# ==========================================
# INITIALIZATION
# ==========================================

func _initialize_dialogue():
	"""Set up default dialogue lines"""
	dialogue_lines = [
		"Greetings, fellow cultivator.",
		"The path to immortality is fraught with danger.",
		"May your journey be enlightening."
	]


func _update_npc_behavior():
	"""Update behavior based on relationship and world state"""
	var karma = StoryStateManager.get_state("karma")
	var reputation = StoryStateManager.get_state("reputation")
	
	# Check sect relationship if affiliated
	if affiliated_sect != "":
		var sect_influence = StoryStateManager.get_sect_influence(affiliated_sect)
		relationship_value = sect_influence
	
	# Determine hostility
	if relationship_value < -50:
		is_hostile = true
		is_ally = false
	elif relationship_value > 50:
		is_hostile = false
		is_ally = true
	else:
		is_hostile = false
		is_ally = false


# ==========================================
# MOVEMENT
# ==========================================

func _physics_process(delta):
	if wander_enabled and not is_hostile:
		_process_wander(delta)


func _process_wander(delta):
	"""Simple wander behavior"""
	wander_timer -= delta
	
	if wander_timer <= 0:
		# Pick new random direction
		wander_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		wander_timer = rand_range(2.0, 5.0)
	
	var velocity = wander_direction * wander_speed
	move_and_slide(velocity)


# ==========================================
# INTERACTION
# ==========================================

func interact(player):
	"""Called when player interacts with this NPC"""
	if not can_talk:
		return
	
	_update_npc_behavior()
	
	if is_hostile:
		_start_combat(player)
	else:
		_start_dialogue()


func _start_dialogue():
	"""Begin dialogue sequence"""
	emit_signal("dialogue_started", npc_name)
	current_dialogue_index = 0
	
	# TODO: Implement actual dialogue UI integration
	print("[NPC %s] Starting dialogue..." % npc_name)
	
	for line in dialogue_lines:
		print("[%s] %s" % [npc_name, line])
	
	emit_signal("dialogue_ended")


func _start_combat(player):
	"""Begin hostile encounter"""
	print("[NPC %s] Attacking player!" % npc_name)
	# TODO: Implement combat AI


# ==========================================
# RELATIONSHIP MANAGEMENT
# ==========================================

func modify_relationship(delta: int):
	"""Change relationship value with this NPC"""
	var old_value = relationship_value
	relationship_value = clamp(relationship_value + delta, -100, 100)
	
	emit_signal("relationship_changed", npc_name, relationship_value)
	_update_npc_behavior()
	
	print("[NPC %s] Relationship: %d -> %d" % [npc_name, old_value, relationship_value])


func give_gift(item_name: String):
	"""Give item to NPC to improve relationship"""
	modify_relationship(10)
	print("[NPC %s] Thank you for the %s!" % [npc_name, item_name])


# ==========================================
# QUEST INTEGRATION
# ==========================================

func offer_quest(quest_data: Dictionary):
	"""Offer a quest to the player"""
	print("[NPC %s] I have a task for you..." % npc_name)
	# TODO: Integrate with quest system


func complete_quest(quest_id: String):
	"""Handle quest completion"""
	modify_relationship(20)
	print("[NPC %s] You have proven yourself worthy!" % npc_name)


# ==========================================
# CAUSAL INTEGRATION
# ==========================================

func react_to_world_event(event_name: String):
	"""React to major world events"""
	match event_name:
		"sect_declares_vendetta":
			if affiliated_sect == "Talisman Sect":
				is_hostile = true
		
		"notorious_villain_status":
			if relationship_value > 0:
				modify_relationship(-30)
		
		"legendary_hero_status":
			if relationship_value < 0 and not is_hostile:
				modify_relationship(20)


# ==========================================
# SAVE/LOAD
# ==========================================

func get_save_data() -> Dictionary:
	"""Return NPC state for saving"""
	return {
		"npc_name": npc_name,
		"position": global_position,
		"relationship_value": relationship_value,
		"is_hostile": is_hostile,
		"is_ally": is_ally
	}


func load_save_data(data: Dictionary):
	"""Restore NPC state"""
	if data.has("position"):
		global_position = data["position"]
	if data.has("relationship_value"):
		relationship_value = data["relationship_value"]
	if data.has("is_hostile"):
		is_hostile = data["is_hostile"]
	if data.has("is_ally"):
		is_ally = data["is_ally"]
	
	_update_npc_behavior()
