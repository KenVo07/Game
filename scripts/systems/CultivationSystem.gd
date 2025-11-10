extends Node

# Cultivation and Realm Management System

signal realm_breakthrough(old_realm, new_realm)
signal sutra_learned(sutra_name)
signal stats_changed(stat_name, old_value, new_value)

# Realm progression
const REALMS = [
	"Mortal",
	"Qi Condensation",
	"Foundation Establishment",
	"Core Formation",
	"Nascent Soul",
	"Saint",
	"True Immortal"
]

# Current cultivation state
var current_realm = "Mortal"
var realm_level = 0
var cultivation_progress = 0.0  # Progress to next realm (0.0 to 1.0)

# Heart Sutra (defines cultivation path)
var heart_sutra = "Heart Sutra of Silent Chaos"

# Learned sutras (technique manuals)
var sutras = []

# Cultivation stats
var stats = {
	"strength": 10,
	"spirit": 10,
	"qi_capacity": 100,
	"qi_current": 100,
	"vitality": 100,
	"comprehension": 10,
	"luck": 5
}

# Breakthrough requirements
var breakthrough_requirements = {
	"Qi Condensation": {"cultivation_progress": 1.0, "spirit": 15},
	"Foundation Establishment": {"cultivation_progress": 1.0, "spirit": 25, "qi_capacity": 200},
	"Core Formation": {"cultivation_progress": 1.0, "spirit": 40, "qi_capacity": 500, "special_item": "Core Condensing Pill"},
	"Nascent Soul": {"cultivation_progress": 1.0, "spirit": 60, "qi_capacity": 1000, "comprehension": 30},
	"Saint": {"cultivation_progress": 1.0, "spirit": 100, "qi_capacity": 2000, "comprehension": 50, "karma": 0},
	"True Immortal": {"cultivation_progress": 1.0, "spirit": 150, "qi_capacity": 5000, "comprehension": 80, "karma": 20}
}

func _ready():
	_initialize_default_sutras()

func _initialize_default_sutras():
	# Start with basic heart sutra
	sutras = ["Heart Sutra of Silent Chaos"]

# Attempt breakthrough to next realm
func attempt_breakthrough() -> bool:
	if realm_level >= REALMS.size() - 1:
		return false  # Already at max realm
	
	var next_realm = REALMS[realm_level + 1]
	
	if can_breakthrough(next_realm):
		var old_realm = current_realm
		realm_level += 1
		current_realm = next_realm
		cultivation_progress = 0.0
		
		# Boost stats on breakthrough
		_apply_breakthrough_bonuses()
		
		# Update story state
		StoryStateManager.modify_state("realm_level", 1, "Breakthrough to " + next_realm)
		
		emit_signal("realm_breakthrough", old_realm, next_realm)
		return true
	
	return false

func can_breakthrough(target_realm: String = "") -> bool:
	if target_realm == "":
		if realm_level >= REALMS.size() - 1:
			return false
		target_realm = REALMS[realm_level + 1]
	
	if not breakthrough_requirements.has(target_realm):
		return true  # No specific requirements
	
	var reqs = breakthrough_requirements[target_realm]
	
	# Check cultivation progress
	if reqs.has("cultivation_progress") and cultivation_progress < reqs["cultivation_progress"]:
		return false
	
	# Check stat requirements
	for stat in ["strength", "spirit", "qi_capacity", "comprehension"]:
		if reqs.has(stat) and stats[stat] < reqs[stat]:
			return false
	
	# Check special requirements
	if reqs.has("special_item"):
		if not _has_item_in_inventory(reqs["special_item"]):
			return false
	
	if reqs.has("karma"):
		if StoryStateManager.world_state["karma"] < reqs["karma"]:
			return false
	
	return true

func _has_item_in_inventory(item_name: String) -> bool:
	return item_name in StoryStateManager.world_state["inventory"]

func _apply_breakthrough_bonuses():
	# Grant stat bonuses based on realm
	var bonuses = {
		"Qi Condensation": {"strength": 5, "spirit": 10, "qi_capacity": 50},
		"Foundation Establishment": {"strength": 10, "spirit": 15, "qi_capacity": 100, "vitality": 50},
		"Core Formation": {"strength": 20, "spirit": 25, "qi_capacity": 300, "vitality": 100},
		"Nascent Soul": {"strength": 30, "spirit": 40, "qi_capacity": 500, "vitality": 200},
		"Saint": {"strength": 50, "spirit": 60, "qi_capacity": 1000, "vitality": 500},
		"True Immortal": {"strength": 100, "spirit": 100, "qi_capacity": 3000, "vitality": 1000}
	}
	
	if bonuses.has(current_realm):
		var realm_bonuses = bonuses[current_realm]
		for stat in realm_bonuses:
			modify_stat(stat, realm_bonuses[stat])

# Modify cultivation stats
func modify_stat(stat_name: String, delta):
	if not stats.has(stat_name):
		push_error("Invalid stat: " + stat_name)
		return
	
	var old_value = stats[stat_name]
	stats[stat_name] += delta
	
	# Clamp certain stats
	if stat_name == "qi_current":
		stats[stat_name] = clamp(stats[stat_name], 0, stats["qi_capacity"])
	
	emit_signal("stats_changed", stat_name, old_value, stats[stat_name])

# Cultivate (gain progress)
func cultivate(duration: float = 1.0):
	# Progress based on comprehension and heart sutra efficiency
	var efficiency = _get_heart_sutra_efficiency()
	var progress_gain = (stats["comprehension"] / 100.0) * efficiency * duration * 0.01
	
	cultivation_progress += progress_gain
	cultivation_progress = clamp(cultivation_progress, 0.0, 1.0)
	
	# Restore qi while cultivating
	modify_stat("qi_current", stats["qi_capacity"] * 0.1 * duration)

func _get_heart_sutra_efficiency() -> float:
	# Different heart sutras have different efficiency
	var efficiencies = {
		"Heart Sutra of Silent Chaos": 1.0,
		"Heart Sutra of Demonic Ascension": 1.5,
		"Heart Sutra of Heavenly Virtue": 1.2,
		"Heart Sutra of Eternal Void": 0.8,
		"Heart Sutra of Supreme Dao": 2.0
	}
	
	return efficiencies.get(heart_sutra, 1.0)

# Learn new sutra
func learn_sutra(sutra_name: String, sutra_type: String = "technique"):
	if sutra_name in sutras:
		return  # Already learned
	
	sutras.append(sutra_name)
	
	if sutra_type == "heart":
		heart_sutra = sutra_name
	
	emit_signal("sutra_learned", sutra_name)
	
	# Add to story state
	if sutra_name not in StoryStateManager.world_state.get("learned_sutras", []):
		if not StoryStateManager.world_state.has("learned_sutras"):
			StoryStateManager.world_state["learned_sutras"] = []
		StoryStateManager.world_state["learned_sutras"].append(sutra_name)

# Get available techniques from sutras
func get_available_techniques() -> Array:
	var techniques = []
	
	# Map sutras to techniques (simplified)
	var sutra_techniques = {
		"Sutra of Thunder Palm": ["Thunder Strike", "Lightning Dash"],
		"Sutra of Shadow Steps": ["Shadow Step", "Phantom Strike"],
		"Sutra of Talisman Arts": ["Fire Talisman", "Ice Talisman", "Lightning Talisman"],
		"Sutra of Veiled Hatred": ["Curse Strike", "Soul Drain"],
		"Sutra of Heavenly Sword": ["Sword Qi", "Heaven Cleaving Slash"]
	}
	
	for sutra in sutras:
		if sutra_techniques.has(sutra):
			for technique in sutra_techniques[sutra]:
				if technique not in techniques:
					techniques.append(technique)
	
	return techniques

# Consume qi for techniques
func consume_qi(amount: int) -> bool:
	if stats["qi_current"] >= amount:
		modify_stat("qi_current", -amount)
		return true
	return false

# Get current cultivation level (0-100)
func get_cultivation_level() -> int:
	return realm_level * 14 + int(cultivation_progress * 14)

# Get stat for display
func get_stat(stat_name: String):
	return stats.get(stat_name, 0)

# Save/Load
func save_to_dict() -> Dictionary:
	return {
		"current_realm": current_realm,
		"realm_level": realm_level,
		"cultivation_progress": cultivation_progress,
		"heart_sutra": heart_sutra,
		"sutras": sutras.duplicate(),
		"stats": stats.duplicate()
	}

func load_from_dict(data: Dictionary):
	if data.has("current_realm"):
		current_realm = data["current_realm"]
	if data.has("realm_level"):
		realm_level = data["realm_level"]
	if data.has("cultivation_progress"):
		cultivation_progress = data["cultivation_progress"]
	if data.has("heart_sutra"):
		heart_sutra = data["heart_sutra"]
	if data.has("sutras"):
		sutras = data["sutras"].duplicate()
	if data.has("stats"):
		stats = data["stats"].duplicate()
