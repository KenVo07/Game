extends Node

# ==========================================
# CULTIVATION SYSTEM
# ==========================================
# Manages realm progression, sutras, and cultivation stats

# Realm definitions (in order)
const REALMS = [
	"Mortal",
	"Qi Condensation",
	"Foundation Establishment",
	"Core Formation",
	"Nascent Soul",
	"Saint",
	"True Immortal"
]

# Current realm state
var current_realm = "Mortal"
var current_realm_index = 0
var realm_progress = 0.0  # 0.0 to 1.0, progress to next realm

# Sutras
var heart_sutra = "Heart Sutra of Silent Chaos"
var heart_sutra_data = {}
var technique_sutras = []  # Array of technique sutras
var sutra_database = {}

# Stats
var stats = {
	"strength": 10,
	"spirit": 10,
	"qi": 100,
	"max_qi": 100,
	"vitality": 100,
	"max_vitality": 100,
	"cultivation_speed": 1.0,
	"comprehension": 10
}

# Signals
signal realm_breakthrough(new_realm)
signal stat_changed(stat_name, old_value, new_value)
signal sutra_learned(sutra_name)
signal qi_changed(current_qi, max_qi)

func _ready():
	print("CultivationSystem initialized")
	initialize_sutra_database()
	load_heart_sutra(heart_sutra)

# ==========================================
# REALM MANAGEMENT
# ==========================================

func get_current_realm() -> String:
	return current_realm

func get_realm_index(realm_name: String = "") -> int:
	"""
	Get the index of a realm (or current realm if not specified)
	"""
	if realm_name == "":
		realm_name = current_realm
	return REALMS.find(realm_name)

func get_next_realm() -> String:
	"""
	Get the name of the next realm
	"""
	if current_realm_index < REALMS.size() - 1:
		return REALMS[current_realm_index + 1]
	return "Max Realm"

func can_breakthrough() -> bool:
	"""
	Check if player can breakthrough to next realm
	"""
	if current_realm_index >= REALMS.size() - 1:
		return false
	
	# Requirements for breakthrough
	if realm_progress >= 1.0:
		# Additional requirements based on realm
		match current_realm:
			"Mortal":
				return stats["qi"] >= 100
			"Qi Condensation":
				return stats["qi"] >= 300 and stats["spirit"] >= 20
			"Foundation Establishment":
				return stats["qi"] >= 1000 and stats["spirit"] >= 40
			"Core Formation":
				return stats["qi"] >= 3000 and stats["spirit"] >= 70
			"Nascent Soul":
				return stats["qi"] >= 10000 and stats["spirit"] >= 100
			"Saint":
				return stats["qi"] >= 30000 and stats["spirit"] >= 150
		return true
	return false

func breakthrough() -> bool:
	"""
	Attempt to breakthrough to next realm
	Returns true if successful
	"""
	if not can_breakthrough():
		return false
	
	current_realm_index += 1
	current_realm = REALMS[current_realm_index]
	realm_progress = 0.0
	
	# Apply realm breakthrough bonuses
	apply_breakthrough_bonuses()
	
	# Update StoryStateManager
	StoryStateManager.set_state("realm_level", current_realm_index + 1)
	
	emit_signal("realm_breakthrough", current_realm)
	StoryStateManager.emit_signal("realm_breakthrough", current_realm)
	
	print("Breakthrough successful! New realm: ", current_realm)
	return true

func apply_breakthrough_bonuses():
	"""
	Apply stat bonuses when breaking through
	"""
	var multiplier = 1.5 + (current_realm_index * 0.3)
	
	modify_stat("max_qi", int(stats["max_qi"] * multiplier) - stats["max_qi"])
	modify_stat("max_vitality", int(stats["max_vitality"] * 1.2) - stats["max_vitality"])
	modify_stat("strength", int(stats["strength"] * 1.3) - stats["strength"])
	modify_stat("spirit", int(stats["spirit"] * 1.3) - stats["spirit"])
	
	# Restore qi and vitality
	stats["qi"] = stats["max_qi"]
	stats["vitality"] = stats["max_vitality"]

func add_realm_progress(amount: float):
	"""
	Add progress towards next realm
	"""
	realm_progress += amount * stats["cultivation_speed"] * get_heart_sutra_efficiency()
	realm_progress = clamp(realm_progress, 0.0, 1.0)

# ==========================================
# STAT MANAGEMENT
# ==========================================

func modify_stat(stat_name: String, delta):
	"""
	Modify a stat by delta amount
	"""
	if not stats.has(stat_name):
		push_error("Stat %s not found" % stat_name)
		return
	
	var old_value = stats[stat_name]
	stats[stat_name] += delta
	
	# Clamp certain stats
	match stat_name:
		"qi":
			stats["qi"] = clamp(stats["qi"], 0, stats["max_qi"])
			emit_signal("qi_changed", stats["qi"], stats["max_qi"])
		"vitality":
			stats["vitality"] = clamp(stats["vitality"], 0, stats["max_vitality"])
	
	emit_signal("stat_changed", stat_name, old_value, stats[stat_name])

func get_stat(stat_name: String):
	"""
	Get a stat value
	"""
	if stats.has(stat_name):
		return stats[stat_name]
	return 0

func set_stat(stat_name: String, value):
	"""
	Directly set a stat value
	"""
	if not stats.has(stat_name):
		push_error("Stat %s not found" % stat_name)
		return
	
	var old_value = stats[stat_name]
	stats[stat_name] = value
	emit_signal("stat_changed", stat_name, old_value, value)

# ==========================================
# SUTRA MANAGEMENT
# ==========================================

func initialize_sutra_database():
	"""
	Initialize the database of available sutras
	"""
	sutra_database = {
		# Heart Sutras (define cultivation path)
		"Heart Sutra of Silent Chaos": {
			"type": "heart",
			"efficiency": 1.0,
			"description": "A balanced cultivation method embracing both light and shadow.",
			"bonuses": {"cultivation_speed": 1.0}
		},
		"Heart Sutra of Veiled Hatred": {
			"type": "heart",
			"efficiency": 1.3,
			"description": "A dark cultivation method fueled by resentment and ambition.",
			"bonuses": {"cultivation_speed": 1.3, "strength": 5},
			"karma_cost": -10
		},
		"Heart Sutra of Celestial Harmony": {
			"type": "heart",
			"efficiency": 1.2,
			"description": "A righteous cultivation method aligned with heavenly laws.",
			"bonuses": {"cultivation_speed": 1.2, "spirit": 5},
			"karma_requirement": 30
		},
		"Heart Sutra of the Eternal Abyss": {
			"type": "heart",
			"efficiency": 1.5,
			"description": "A forbidden method that draws power from the void itself.",
			"bonuses": {"cultivation_speed": 1.5, "max_qi": 50},
			"karma_requirement": -50
		},
		
		# Combat/Technique Sutras
		"Talisman Strike Sutra": {
			"type": "combat",
			"description": "Basic talisman combat techniques.",
			"unlocks": ["Talisman Strike", "Qi Burst"]
		},
		"Shadow Step Manual": {
			"type": "movement",
			"description": "Advanced movement techniques using shadow qi.",
			"unlocks": ["Shadow Step", "Phantom Dash"]
		},
		"Blood Demon Arts": {
			"type": "combat",
			"description": "Demonic combat arts that consume vitality for power.",
			"unlocks": ["Blood Strike", "Life Drain"],
			"karma_requirement": -30
		},
		"Celestial Blade Codex": {
			"type": "combat",
			"description": "Righteous sword techniques blessed by heaven.",
			"unlocks": ["Heaven's Judgment", "Purifying Light"],
			"karma_requirement": 30
		},
	}

func load_heart_sutra(sutra_name: String):
	"""
	Load a heart sutra (replaces current one)
	"""
	if not sutra_database.has(sutra_name):
		push_error("Sutra %s not found in database" % sutra_name)
		return false
	
	var sutra = sutra_database[sutra_name]
	if sutra["type"] != "heart":
		push_error("%s is not a heart sutra" % sutra_name)
		return false
	
	# Check requirements
	if sutra.has("karma_requirement"):
		if StoryStateManager.get_state("karma") < sutra["karma_requirement"]:
			print("Insufficient karma to learn %s" % sutra_name)
			return false
	
	# Apply karma cost if any
	if sutra.has("karma_cost"):
		StoryStateManager.modify_state("karma", sutra["karma_cost"])
	
	heart_sutra = sutra_name
	heart_sutra_data = sutra
	
	# Apply bonuses
	if sutra.has("bonuses"):
		for stat in sutra["bonuses"]:
			if stats.has(stat):
				modify_stat(stat, sutra["bonuses"][stat])
	
	# Update StoryStateManager
	StoryStateManager.set_state("heart_sutra", sutra_name)
	
	emit_signal("sutra_learned", sutra_name)
	print("Learned Heart Sutra: ", sutra_name)
	return true

func learn_technique_sutra(sutra_name: String) -> bool:
	"""
	Learn a technique/combat sutra
	"""
	if not sutra_database.has(sutra_name):
		push_error("Sutra %s not found in database" % sutra_name)
		return false
	
	var sutra = sutra_database[sutra_name]
	if sutra["type"] == "heart":
		push_error("%s is a heart sutra, use load_heart_sutra instead" % sutra_name)
		return false
	
	# Check if already learned
	if has_sutra(sutra_name):
		print("Already learned %s" % sutra_name)
		return false
	
	# Check requirements
	if sutra.has("karma_requirement"):
		if StoryStateManager.get_state("karma") < sutra["karma_requirement"]:
			print("Insufficient karma to learn %s" % sutra_name)
			return false
	
	technique_sutras.append(sutra_name)
	emit_signal("sutra_learned", sutra_name)
	
	# Unlock abilities if specified
	if sutra.has("unlocks"):
		for ability in sutra["unlocks"]:
			AbilitySystem.unlock_technique(ability)
	
	print("Learned Technique Sutra: ", sutra_name)
	return true

func has_sutra(sutra_name: String) -> bool:
	"""
	Check if player has learned a sutra
	"""
	if sutra_name == heart_sutra:
		return true
	return sutra_name in technique_sutras

func get_heart_sutra_efficiency() -> float:
	"""
	Get cultivation efficiency multiplier from heart sutra
	"""
	if heart_sutra_data.has("efficiency"):
		return heart_sutra_data["efficiency"]
	return 1.0

func get_sutra_info(sutra_name: String) -> Dictionary:
	"""
	Get information about a sutra
	"""
	if sutra_database.has(sutra_name):
		return sutra_database[sutra_name]
	return {}

# ==========================================
# CULTIVATION ACTIONS
# ==========================================

func cultivate(duration: float):
	"""
	Perform cultivation for a duration (in seconds)
	"""
	var qi_gain = duration * stats["cultivation_speed"] * get_heart_sutra_efficiency() * 10
	var realm_gain = duration * 0.01 * stats["cultivation_speed"] * get_heart_sutra_efficiency()
	
	modify_stat("qi", int(qi_gain))
	add_realm_progress(realm_gain)

func consume_qi(amount: int) -> bool:
	"""
	Consume qi for techniques. Returns true if successful
	"""
	if stats["qi"] >= amount:
		modify_stat("qi", -amount)
		return true
	return false

func restore_qi(amount: int):
	"""
	Restore qi
	"""
	modify_stat("qi", amount)

# ==========================================
# SERIALIZATION
# ==========================================

func get_save_data() -> Dictionary:
	"""
	Get data to save
	"""
	return {
		"current_realm": current_realm,
		"current_realm_index": current_realm_index,
		"realm_progress": realm_progress,
		"heart_sutra": heart_sutra,
		"technique_sutras": technique_sutras,
		"stats": stats.duplicate()
	}

func load_save_data(data: Dictionary):
	"""
	Load data from save
	"""
	if data.has("current_realm"):
		current_realm = data["current_realm"]
	if data.has("current_realm_index"):
		current_realm_index = data["current_realm_index"]
	if data.has("realm_progress"):
		realm_progress = data["realm_progress"]
	if data.has("heart_sutra"):
		heart_sutra = data["heart_sutra"]
		if sutra_database.has(heart_sutra):
			heart_sutra_data = sutra_database[heart_sutra]
	if data.has("technique_sutras"):
		technique_sutras = data["technique_sutras"]
	if data.has("stats"):
		stats = data["stats"]
	
	print("Cultivation data loaded")

# ==========================================
# DEBUGGING
# ==========================================

func print_cultivation_status():
	"""
	Print current cultivation status for debugging
	"""
	print("=== CULTIVATION STATUS ===")
	print("Realm: ", current_realm, " (", current_realm_index, ")")
	print("Progress: ", realm_progress * 100, "%")
	print("Heart Sutra: ", heart_sutra)
	print("Technique Sutras: ", technique_sutras)
	print("Stats:")
	for stat in stats:
		print("  ", stat, ": ", stats[stat])
	print("=========================")
