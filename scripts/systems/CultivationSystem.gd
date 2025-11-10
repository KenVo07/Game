extends Node

# ==========================================
# CULTIVATION SYSTEM
# Manages realms, sutras, breakthroughs, and cultivation stats
# ==========================================

signal realm_breakthrough(old_realm, new_realm)
signal sutra_learned(sutra_name, sutra_type)
signal cultivation_progress(current_progress, max_progress)
signal stat_increased(stat_name, new_value)

# Cultivation Realms (in order)
const REALMS = [
	"Mortal",
	"Qi Condensation",
	"Foundation Establishment",
	"Core Formation",
	"Nascent Soul",
	"Saint Realm",
	"True Immortal"
]

# Current Cultivation State
var current_realm: String = "Mortal"
var current_realm_index: int = 0
var cultivation_progress: float = 0.0
var cultivation_required: float = 100.0

# Heart Sutra (defines cultivation path)
var heart_sutra: String = "Heart Sutra of Silent Chaos"
var heart_sutra_efficiency: float = 1.0

# Learned Sutras (techniques and abilities)
var learned_sutras: Array = []

# Combat Stats
var stats = {
	"strength": 10,
	"agility": 10,
	"spirit": 10,
	"vitality": 10,
	"qi_capacity": 100,
	"qi_current": 100,
	"qi_regen": 1.0
}

# Sutra Database
var sutra_database = {
	# Heart Sutras (cultivation paths)
	"Heart Sutra of Silent Chaos": {
		"type": "heart",
		"description": "A dark path that grows stronger through conflict and chaos.",
		"efficiency": 1.0,
		"stat_bonus": {"strength": 2, "spirit": 3},
		"special": "Gain cultivation progress from negative karma actions"
	},
	"Heart Sutra of Celestial Harmony": {
		"type": "heart",
		"description": "The righteous path that strengthens through virtue.",
		"efficiency": 0.9,
		"stat_bonus": {"vitality": 3, "spirit": 2},
		"special": "Gain cultivation progress from positive karma actions"
	},
	"Heart Sutra of the Eternal Void": {
		"type": "heart",
		"description": "A mysterious path that transcends morality.",
		"efficiency": 1.2,
		"stat_bonus": {"qi_capacity": 50, "spirit": 5},
		"special": "Neutral actions grant double cultivation progress"
	},
	
	# Combat Sutras
	"Sutra of the Crimson Blade": {
		"type": "combat",
		"description": "Mastery of blood-infused sword techniques.",
		"stat_bonus": {"strength": 5, "agility": 3},
		"abilities": ["Crimson Slash", "Blood Resonance"]
	},
	"Sutra of Shadow Steps": {
		"type": "movement",
		"description": "Movement technique that bends shadows.",
		"stat_bonus": {"agility": 7},
		"abilities": ["Shadow Dash", "Phantom Strike"]
	},
	"Sutra of Veiled Hatred": {
		"type": "combat",
		"description": "Dark technique that feeds on negative emotions.",
		"stat_bonus": {"spirit": 6, "strength": 2},
		"abilities": ["Hatred Bolt", "Curse Mark"]
	},
	"Sutra of Talisman Mastery": {
		"type": "utility",
		"description": "Control and craft talismans with greater efficiency.",
		"stat_bonus": {"spirit": 5},
		"abilities": ["Rapid Talisman", "Talisman Overcharge"]
	}
}


func _ready():
	print("[CultivationSystem] Initialized")
	_connect_to_story_state()


func _connect_to_story_state():
	"""Connect to StoryStateManager for synced updates"""
	if StoryStateManager:
		StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")


# ==========================================
# REALM PROGRESSION
# ==========================================

func add_cultivation_progress(amount: float):
	"""Add cultivation progress (modified by heart sutra efficiency)"""
	var modified_amount = amount * heart_sutra_efficiency
	cultivation_progress += modified_amount
	
	emit_signal("cultivation_progress", cultivation_progress, cultivation_required)
	
	# Check for breakthrough
	if cultivation_progress >= cultivation_required:
		attempt_breakthrough()


func attempt_breakthrough() -> bool:
	"""Attempt to break through to next realm"""
	if current_realm_index >= REALMS.size() - 1:
		print("[Cultivation] Already at maximum realm: True Immortal")
		return false
	
	if cultivation_progress < cultivation_required:
		print("[Cultivation] Insufficient progress for breakthrough")
		return false
	
	# Check if karma/conditions allow breakthrough
	var karma = StoryStateManager.get_state("karma")
	var can_breakthrough = true
	
	# Some realms require specific conditions
	match current_realm_index:
		2: # Foundation Establishment requires positive or negative karma > 20
			if abs(karma) < 20:
				can_breakthrough = false
				print("[Cultivation] Foundation Establishment requires stronger conviction (karma)")
		4: # Nascent Soul requires facing tribulation
			if not StoryStateManager.get_flag("tribulation_survived"):
				can_breakthrough = false
				print("[Cultivation] Nascent Soul requires surviving Heavenly Tribulation")
	
	if not can_breakthrough:
		return false
	
	# Perform breakthrough
	var old_realm = current_realm
	current_realm_index += 1
	current_realm = REALMS[current_realm_index]
	
	# Reset progress for next realm
	cultivation_progress = 0
	cultivation_required = cultivation_required * 1.5  # Each realm takes longer
	
	# Grant stat increases
	_apply_breakthrough_bonuses()
	
	# Update story state
	StoryStateManager.modify_state("realm_level", current_realm_index, true)
	
	emit_signal("realm_breakthrough", old_realm, current_realm)
	print("[Cultivation] Breakthrough! %s -> %s" % [old_realm, current_realm])
	
	return true


func _apply_breakthrough_bonuses():
	"""Apply stat bonuses from breakthrough"""
	var base_bonus = 5 + (current_realm_index * 2)
	
	stats["strength"] += base_bonus
	stats["agility"] += base_bonus
	stats["spirit"] += base_bonus
	stats["vitality"] += base_bonus
	stats["qi_capacity"] += 50 * current_realm_index
	stats["qi_current"] = stats["qi_capacity"]
	
	print("[Cultivation] Stats increased from breakthrough")


func force_breakthrough():
	"""Debug function - force breakthrough regardless of conditions"""
	if current_realm_index >= REALMS.size() - 1:
		return
	
	cultivation_progress = cultivation_required
	attempt_breakthrough()


# ==========================================
# SUTRA SYSTEM
# ==========================================

func learn_sutra(sutra_name: String) -> bool:
	"""Learn a new sutra"""
	if not sutra_database.has(sutra_name):
		push_error("Sutra not found in database: " + sutra_name)
		return false
	
	if sutra_name in learned_sutras:
		print("[Cultivation] Already learned: " + sutra_name)
		return false
	
	var sutra_data = sutra_database[sutra_name]
	learned_sutras.append(sutra_name)
	
	# Apply stat bonuses
	if sutra_data.has("stat_bonus"):
		for stat in sutra_data["stat_bonus"].keys():
			if stats.has(stat):
				stats[stat] += sutra_data["stat_bonus"][stat]
				emit_signal("stat_increased", stat, stats[stat])
	
	# If it's a heart sutra, switch to it
	if sutra_data["type"] == "heart":
		set_heart_sutra(sutra_name)
	
	# Unlock abilities if present
	if sutra_data.has("abilities"):
		for ability in sutra_data["abilities"]:
			AbilitySystem.unlock_technique_ability(ability, sutra_name)
	
	emit_signal("sutra_learned", sutra_name, sutra_data["type"])
	print("[Cultivation] Learned sutra: " + sutra_name)
	
	return true


func set_heart_sutra(sutra_name: String):
	"""Change current heart sutra (cultivation path)"""
	if not sutra_database.has(sutra_name):
		return
	
	var sutra_data = sutra_database[sutra_name]
	if sutra_data["type"] != "heart":
		print("[Cultivation] Can only set heart sutras as cultivation path")
		return
	
	heart_sutra = sutra_name
	heart_sutra_efficiency = sutra_data.get("efficiency", 1.0)
	
	StoryStateManager.modify_state("heart_sutra", heart_sutra, true)
	print("[Cultivation] Heart Sutra changed to: " + sutra_name)


func get_learned_sutras() -> Array:
	"""Return list of all learned sutras"""
	return learned_sutras.duplicate()


func has_sutra(sutra_name: String) -> bool:
	"""Check if player has learned a specific sutra"""
	return sutra_name in learned_sutras


# ==========================================
# STAT MANAGEMENT
# ==========================================

func get_stat(stat_name: String):
	"""Get current value of a stat"""
	return stats.get(stat_name, 0)


func modify_stat(stat_name: String, delta):
	"""Modify a stat value"""
	if stats.has(stat_name):
		stats[stat_name] += delta
		emit_signal("stat_increased", stat_name, stats[stat_name])


func get_all_stats() -> Dictionary:
	"""Return copy of all stats"""
	return stats.duplicate()


func consume_qi(amount: float) -> bool:
	"""Consume qi for techniques (returns false if insufficient)"""
	if stats["qi_current"] >= amount:
		stats["qi_current"] -= amount
		return true
	return false


func restore_qi(amount: float):
	"""Restore qi"""
	stats["qi_current"] = min(stats["qi_current"] + amount, stats["qi_capacity"])


func _process(delta):
	"""Regenerate qi over time"""
	if stats["qi_current"] < stats["qi_capacity"]:
		restore_qi(stats["qi_regen"] * delta)


# ==========================================
# INTEGRATION WITH STORY STATE
# ==========================================

func _on_world_state_changed(variable_name: String, old_value, new_value):
	"""React to story state changes"""
	match variable_name:
		"karma":
			# Gain cultivation from extreme karma actions
			if heart_sutra == "Heart Sutra of Silent Chaos":
				if new_value < old_value:  # Negative action
					add_cultivation_progress(abs(new_value - old_value) * 0.5)
			elif heart_sutra == "Heart Sutra of Celestial Harmony":
				if new_value > old_value:  # Positive action
					add_cultivation_progress(abs(new_value - old_value) * 0.5)


# ==========================================
# SAVE/LOAD INTERFACE
# ==========================================

func get_save_data() -> Dictionary:
	"""Return cultivation data for saving"""
	return {
		"current_realm": current_realm,
		"current_realm_index": current_realm_index,
		"cultivation_progress": cultivation_progress,
		"cultivation_required": cultivation_required,
		"heart_sutra": heart_sutra,
		"heart_sutra_efficiency": heart_sutra_efficiency,
		"learned_sutras": learned_sutras.duplicate(),
		"stats": stats.duplicate()
	}


func load_save_data(data: Dictionary):
	"""Restore cultivation data from save"""
	current_realm = data.get("current_realm", "Mortal")
	current_realm_index = data.get("current_realm_index", 0)
	cultivation_progress = data.get("cultivation_progress", 0.0)
	cultivation_required = data.get("cultivation_required", 100.0)
	heart_sutra = data.get("heart_sutra", "Heart Sutra of Silent Chaos")
	heart_sutra_efficiency = data.get("heart_sutra_efficiency", 1.0)
	learned_sutras = data.get("learned_sutras", [])
	stats = data.get("stats", stats)
	
	print("[CultivationSystem] Loaded saved data")


# ==========================================
# DEBUG
# ==========================================

func print_cultivation_info():
	"""Debug print current cultivation state"""
	print("========== CULTIVATION INFO ==========")
	print("Realm: %s (%d/%d)" % [current_realm, current_realm_index, REALMS.size() - 1])
	print("Progress: %.1f / %.1f" % [cultivation_progress, cultivation_required])
	print("Heart Sutra: %s (%.1fx efficiency)" % [heart_sutra, heart_sutra_efficiency])
	print("Learned Sutras: %s" % str(learned_sutras))
	print("Stats: %s" % str(stats))
	print("======================================")
