extends KinematicBody2D

# NPC - Non-Player Character with dynamic behavior based on world state

export var npc_name = "Mysterious Cultivator"
export var npc_faction = "None"
export var base_attitude = 0  # -100 to 100

var current_attitude = 0
var can_interact = false
var player_in_range = false

# Dialogue data
var dialogue_tree = {}
var current_dialogue_id = "greeting"

onready var sprite = $Sprite
onready var interaction_area = $InteractionArea
onready var label = $Label

func _ready():
	current_attitude = base_attitude
	_update_attitude()
	_setup_dialogue()
	
	if label:
		label.text = npc_name
	
	if interaction_area:
		interaction_area.connect("body_entered", self, "_on_interaction_area_entered")
		interaction_area.connect("body_exited", self, "_on_interaction_area_exited")
	
	add_to_group("npcs")
	
	# Register with story state
	if npc_name not in StoryStateManager.world_state["npcs_met"]:
		# Not yet met

		pass

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		interact()

func _update_attitude():
	# Calculate attitude based on world state
	var karma = StoryStateManager.world_state["karma"]
	var reputation = StoryStateManager.world_state["reputation"]
	
	# Faction influence
	if npc_faction != "None" and StoryStateManager.world_state["sect_influence"].has(npc_faction):
		var faction_influence = StoryStateManager.world_state["sect_influence"][npc_faction]
		current_attitude = base_attitude + faction_influence
	else:
		current_attitude = base_attitude
	
	# Karma influence
	current_attitude += karma * 0.2
	
	# Check if faction is enemy
	if npc_faction in StoryStateManager.world_state["enemies"]:
		current_attitude -= 50
	elif npc_faction in StoryStateManager.world_state["alliances"]:
		current_attitude += 30
	
	current_attitude = clamp(current_attitude, -100, 100)

func _setup_dialogue():
	# Define dialogue tree
	dialogue_tree = {
		"greeting": {
			"text": "Greetings, cultivator. What brings you here?",
			"conditions": [],
			"options": [
				{"text": "I seek knowledge.", "next": "knowledge_path"},
				{"text": "I'm just passing through.", "next": "goodbye"},
				{"text": "Your sect will fall.", "next": "hostile", "karma": -10}
			]
		},
		"knowledge_path": {
			"text": "Ah, a seeker of the Dao. I respect that.",
			"conditions": [],
			"options": [
				{"text": "Can you teach me?", "next": "teaching"},
				{"text": "Tell me about this region.", "next": "lore"},
				{"text": "Farewell.", "next": "goodbye"}
			]
		},
		"teaching": {
			"text": "Very well. Here is a technique I learned long ago...",
			"conditions": ["reputation >= 20"],
			"options": [
				{"text": "Thank you, master.", "next": "goodbye", "reward": "sutra"}
			],
			"fail_text": "You are not worthy yet. Return when your reputation is greater."
		},
		"lore": {
			"text": "This land was once ruled by the Ancient Immortals. Their ruins still hold power...",
			"conditions": [],
			"options": [
				{"text": "Tell me more.", "next": "lore_deep"},
				{"text": "I see.", "next": "goodbye"}
			]
		},
		"lore_deep": {
			"text": "The Moon Pavilion guards a secret. A portal to the celestial realm.",
			"conditions": [],
			"options": [
				{"text": "Fascinating.", "next": "goodbye", "reward": "insight"}
			]
		},
		"hostile": {
			"text": "How dare you! Guards, attack this villain!",
			"conditions": [],
			"options": [],
			"trigger": "combat"
		},
		"goodbye": {
			"text": "May the heavens guide your path.",
			"conditions": [],
			"options": [],
			"end": true
		}
	}

func interact():
	if not can_interact:
		return
	
	_update_attitude()
	
	# Mark as met
	if npc_name not in StoryStateManager.world_state["npcs_met"]:
		StoryStateManager.world_state["npcs_met"].append(npc_name)
	
	# Check attitude
	if current_attitude < -50:
		# Hostile
		_start_dialogue("hostile")
	else:
		_start_dialogue("greeting")

func _start_dialogue(dialogue_id: String):
	if not dialogue_tree.has(dialogue_id):
		return
	
	var dialogue = dialogue_tree[dialogue_id]
	
	# Check conditions
	if dialogue.has("conditions") and dialogue["conditions"].size() > 0:
		var conditions_met = true
		for condition in dialogue["conditions"]:
			if not StoryStateManager.query_state(condition):
				conditions_met = false
				break
		
		if not conditions_met and dialogue.has("fail_text"):
			_show_dialogue_popup(dialogue["fail_text"], [])
			return
	
	# Show dialogue
	_show_dialogue_popup(dialogue["text"], dialogue.get("options", []))
	
	# Handle special triggers
	if dialogue.has("trigger"):
		match dialogue["trigger"]:
			"combat":
				_trigger_combat()
	
	# Handle end
	if dialogue.get("end", false):
		_end_dialogue()

func _show_dialogue_popup(text: String, options: Array):
	# This would integrate with a DialogueManager or UI system
	print("\n=== %s ===" % npc_name)
	print(text)
	
	if options.size() > 0:
		print("\nOptions:")
		for i in range(options.size()):
			var option = options[i]
			print("  %d. %s" % [i + 1, option["text"]])

func _handle_dialogue_choice(option: Dictionary):
	# Apply karma changes
	if option.has("karma"):
		StoryStateManager.modify_state("karma", option["karma"], "Dialogue choice")
	
	# Apply rewards
	if option.has("reward"):
		match option["reward"]:
			"sutra":
				var sutra = "Sutra of %s" % npc_name.replace(" ", "_")
				CultivationSystem.learn_sutra(sutra)
			"insight":
				var insight = "The %s knows secrets about %s" % [npc_name, npc_faction]
				if insight not in StoryStateManager.world_state["insight_clues"]:
					StoryStateManager.world_state["insight_clues"].append(insight)
			"item":
				# Add item to inventory
				pass
	
	# Continue to next dialogue
	if option.has("next"):
		_start_dialogue(option["next"])

func _trigger_combat():
	# Spawn hostile enemies or make this NPC hostile
	print("Combat initiated with %s!" % npc_name)
	# TODO: Implement combat trigger

func _end_dialogue():
	print("=== Dialogue ended ===\n")

func _on_interaction_area_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		can_interact = true
		
		# Show interaction prompt
		if label:
			label.text = npc_name + " [E]"

func _on_interaction_area_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		can_interact = false
		
		if label:
			label.text = npc_name
