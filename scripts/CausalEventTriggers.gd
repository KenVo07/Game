extends Node

# ==========================================
# CAUSAL EVENT TRIGGERS
# ==========================================
# Example implementations of causal events
# This script demonstrates how to create complex event chains

"""
EXAMPLE CAUSAL CHAIN:

1. Player destroys Sacred Talisman
   → karma -15, sect_influence["Talisman Sect"] -30
   
2. Elder Feng warns the player (NPC dialogue changes)
   
3. If ignored → SectRaid event triggers
   
4. If player dies in raid → Simulation records "Sect's Vengeance"
   
5. Player reads simulation log, learns Elder Feng's weakness
   
6. Player allies with rival sect → new path opens
   
7. World consequence: Daxia Empire weakened permanently
"""

# Track event states
var events_triggered = {}
var event_cooldowns = {}

func _ready():
	# Connect to story state signals
	StoryStateManager.connect("causal_event_triggered", self, "_on_causal_event")
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")
	
	print("[CausalEventTriggers] Loaded example causal event system")

func _on_world_state_changed(variable_name: String, old_value, new_value):
	"""React to world state changes"""
	match variable_name:
		"destroyed_artifacts":
			_check_artifact_destruction(new_value)
		"killed_npcs":
			_check_npc_killed(new_value)
		"saved_npcs":
			_check_npc_saved(new_value)
		"karma":
			_check_karma_threshold(new_value)

func _on_causal_event(event_name: String, data: Dictionary):
	"""React to causal events"""
	print("[CausalEventTriggers] Processing event: " + event_name)
	
	# Mark event as triggered
	events_triggered[event_name] = true
	
	# Handle specific events
	match event_name:
		"heavenly_tribulation":
			_spawn_tribulation_encounter()
		"sect_revenge_raid":
			_spawn_sect_raid()
		"demonic_path_unlock":
			_unlock_demonic_techniques()
		"righteous_path_unlock":
			_unlock_righteous_path()

# ==========================================
# ARTIFACT DESTRUCTION EVENTS
# ==========================================

func _check_artifact_destruction(artifact_name):
	"""Check which artifact was destroyed and trigger consequences"""
	if typeof(artifact_name) != TYPE_ARRAY:
		artifact_name = [artifact_name]
	
	for artifact in artifact_name:
		match artifact:
			"Sacred Talisman":
				_trigger_sacred_talisman_destroyed()
			"Sect Altar":
				_trigger_sect_altar_destroyed()
			"Heaven's Gate Seal":
				_trigger_heavens_gate_unsealed()

func _trigger_sacred_talisman_destroyed():
	"""Sacred Talisman was destroyed"""
	print("[CausalEventTriggers] Sacred Talisman destroyed - consequences incoming")
	
	# Immediate consequences
	StoryStateManager.apply_causal_action({
		"karma": -15,
		"sect_influence": {"Talisman Sect": -30},
		"enemies": "Elder Feng"
	})
	
	# Set up delayed event
	yield(get_tree().create_timer(5.0), "timeout")
	
	if not events_triggered.get("ignored_elder_feng_warning", false):
		_trigger_elder_feng_warning()

func _trigger_elder_feng_warning():
	"""Elder Feng appears to warn the player"""
	print("[CausalEventTriggers] Elder Feng appears with a warning...")
	
	# In full implementation, this would:
	# - Spawn Elder Feng NPC
	# - Trigger dialogue
	# - Set flag for player's response
	
	# For now, simulate ignored warning after delay
	yield(get_tree().create_timer(10.0), "timeout")
	
	# Check if player heeded warning
	if StoryStateManager.get_state("sect_influence").get("Talisman Sect", 0) < -20:
		# Still hostile - trigger raid
		events_triggered["ignored_elder_feng_warning"] = true
		StoryStateManager.trigger_event("sect_revenge_raid")

func _trigger_sect_altar_destroyed():
	"""Sect altar was destroyed"""
	print("[CausalEventTriggers] Sect Altar destroyed - sects unite against you")
	
	StoryStateManager.apply_causal_action({
		"karma": -25,
		"sect_influence": {
			"Talisman Sect": -40,
			"Heaven Sect": -30,
			"Moon Pavilion": -20
		},
		"reputation": -50
	})

func _trigger_heavens_gate_unsealed():
	"""Heaven's Gate Seal was broken"""
	print("[CausalEventTriggers] Heaven's Gate unsealed - ancient powers stir")
	
	StoryStateManager.apply_causal_action({
		"destiny_thread": 100,
		"karma": -50
	})
	
	# Unlock special event
	StoryStateManager.trigger_event("ancient_evil_released")

# ==========================================
# NPC INTERACTION EVENTS
# ==========================================

func _check_npc_killed(npc_name):
	"""Handle NPC death consequences"""
	if typeof(npc_name) != TYPE_ARRAY:
		npc_name = [npc_name]
	
	for npc in npc_name:
		match npc:
			"Elder Feng":
				_on_elder_feng_killed()
			"Sect Master Chen":
				_on_sect_master_killed()
			"Mysterious Wanderer":
				_on_wanderer_killed()

func _on_elder_feng_killed():
	"""Player killed Elder Feng"""
	print("[CausalEventTriggers] Elder Feng slain - Talisman Sect declares war")
	
	StoryStateManager.apply_causal_action({
		"karma": -30,
		"sect_influence": {"Talisman Sect": -100},
		"enemies": "Talisman Sect Master"
	})
	
	# Trigger full-scale war event
	events_triggered["talisman_sect_war"] = true

func _on_sect_master_killed():
	"""Player killed a sect master"""
	print("[CausalEventTriggers] Sect Master slain - you are now a wanted criminal")
	
	StoryStateManager.apply_causal_action({
		"karma": -50,
		"reputation": -100
	})
	
	# All sects become hostile
	for sect in ["Talisman Sect", "Heaven Sect", "Moon Pavilion"]:
		StoryStateManager.modify_state("sect_influence", {sect: -100})

func _on_wanderer_killed():
	"""Player killed the mysterious wanderer (bad idea!)"""
	print("[CausalEventTriggers] You killed the Wanderer... reality fractures")
	
	StoryStateManager.apply_causal_action({
		"karma": -100,
		"faith_in_system": -50,
		"destiny_thread": -100
	})
	
	# Trigger reality collapse event
	StoryStateManager.trigger_event("reality_fracture")

func _check_npc_saved(npc_name):
	"""Handle NPC saving consequences"""
	if typeof(npc_name) != TYPE_ARRAY:
		npc_name = [npc_name]
	
	for npc in npc_name:
		match npc:
			"Village Elder":
				_on_village_elder_saved()
			"Injured Disciple":
				_on_disciple_saved()

func _on_village_elder_saved():
	"""Player saved the village elder"""
	print("[CausalEventTriggers] Village Elder saved - you earn the gratitude of the people")
	
	StoryStateManager.apply_causal_action({
		"karma": 20,
		"reputation": 30,
		"alliances": "Spirit Village"
	})

func _on_disciple_saved():
	"""Player saved an injured disciple"""
	print("[CausalEventTriggers] Disciple saved - sect relations improve")
	
	StoryStateManager.apply_causal_action({
		"karma": 10,
		"sect_influence": {"Heaven Sect": 15}
	})

# ==========================================
# KARMA THRESHOLD EVENTS
# ==========================================

func _check_karma_threshold(karma_value: int):
	"""Check if karma crossed important thresholds"""
	if karma_value <= -100 and not events_triggered.get("ultimate_evil", false):
		_trigger_ultimate_evil_path()
	elif karma_value >= 100 and not events_triggered.get("ultimate_good", false):
		_trigger_ultimate_good_path()

func _trigger_ultimate_evil_path():
	"""Player has become ultimate evil"""
	print("[CausalEventTriggers] ULTIMATE EVIL PATH UNLOCKED")
	events_triggered["ultimate_evil"] = true
	
	StoryStateManager.modify_state("insight_clues", "The path to Demon Emperor revealed")
	
	# Unlock demonic transformation
	CultivationSystem.learn_sutra("Demon Emperor's Heart Sutra", "heart")

func _trigger_ultimate_good_path():
	"""Player has become ultimate good"""
	print("[CausalEventTriggers] ULTIMATE GOOD PATH UNLOCKED")
	events_triggered["ultimate_good"] = true
	
	StoryStateManager.modify_state("insight_clues", "The Heavenly Ascension path opens")
	
	# Unlock heavenly transformation
	CultivationSystem.learn_sutra("Heavenly Saint's Heart Sutra", "heart")

# ==========================================
# COMBAT ENCOUNTER SPAWNING
# ==========================================

func _spawn_tribulation_encounter():
	"""Spawn heavenly tribulation encounter"""
	print("[CausalEventTriggers] Spawning Heavenly Tribulation...")
	# Would spawn special boss encounter
	# For now just print
	pass

func _spawn_sect_raid():
	"""Spawn sect revenge raid"""
	print("[CausalEventTriggers] Spawning Sect Raid encounter...")
	# Would spawn multiple sect disciples as enemies
	pass

# ==========================================
# PATH UNLOCKS
# ==========================================

func _unlock_demonic_techniques():
	"""Unlock demonic cultivation"""
	print("[CausalEventTriggers] Demonic techniques unlocked")
	
	# Grant demonic sutras
	CultivationSystem.learn_sutra("Blood Refinement Technique", "combat")
	CultivationSystem.learn_sutra("Soul Devouring Art", "technique")
	
	# Add to inventory
	StoryStateManager.modify_state("inventory", "Demonic Cultivation Manual")

func _unlock_righteous_path():
	"""Unlock righteous cultivation"""
	print("[CausalEventTriggers] Righteous path unlocked")
	
	# Grant righteous sutras
	CultivationSystem.learn_sutra("Heavenly Light Palm", "combat")
	CultivationSystem.learn_sutra("Purification Mantra", "technique")
	
	# Add to inventory
	StoryStateManager.modify_state("inventory", "Heavenly Manual")

# ==========================================
# COMPLEX EVENT CHAINS
# ==========================================

func trigger_moon_pavilion_quest():
	"""Example of a complex multi-stage quest"""
	print("[CausalEventTriggers] Moon Pavilion Quest chain starting...")
	
	# Stage 1: Initial contact
	StoryStateManager.modify_state("insight_clues", "Moon Pavilion seeks your aid")
	
	yield(get_tree().create_timer(5.0), "timeout")
	
	# Stage 2: Quest objective
	if StoryStateManager.get_state("karma") > 0:
		print("[CausalEventTriggers] Moon Pavilion trusts you")
		StoryStateManager.modify_state("sect_influence", {"Moon Pavilion": 30})
	else:
		print("[CausalEventTriggers] Moon Pavilion is wary")
		StoryStateManager.modify_state("sect_influence", {"Moon Pavilion": -10})
