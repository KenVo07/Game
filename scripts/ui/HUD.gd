extends Control

# ==========================================
# HUD - Heads Up Display
# ==========================================
# Shows player stats during gameplay

onready var health_bar = $VBoxContainer/HealthBar
onready var qi_bar = $VBoxContainer/QiBar
onready var realm_label = $TopRight/VBoxContainer/RealmLabel
onready var karma_label = $TopRight/VBoxContainer/KarmaLabel
onready var simulation_count_label = $TopRight/VBoxContainer/SimulationLabel

func _ready():
	# Connect to player signals
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player[0].connect("health_changed", self, "_on_health_changed")
		player[0].connect("qi_changed", self, "_on_qi_changed")
	
	# Connect to system signals
	CultivationSystem.connect("realm_breakthrough", self, "_on_realm_breakthrough")
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")
	
	_update_all_displays()

func _update_all_displays():
	"""Update all HUD elements"""
	_update_health_display()
	_update_qi_display()
	_update_realm_display()
	_update_karma_display()
	_update_simulation_count()

func _update_health_display():
	"""Update health bar"""
	if health_bar:
		health_bar.max_value = CultivationSystem.stats["health_max"]
		health_bar.value = CultivationSystem.stats["health"]

func _update_qi_display():
	"""Update qi bar"""
	if qi_bar:
		qi_bar.max_value = CultivationSystem.stats["qi_max"]
		qi_bar.value = CultivationSystem.stats["qi"]

func _update_realm_display():
	"""Update realm label"""
	if realm_label:
		realm_label.text = "Realm: " + CultivationSystem.current_realm

func _update_karma_display():
	"""Update karma label"""
	if karma_label:
		var karma = StoryStateManager.get_state("karma")
		var karma_desc = _get_karma_description(karma)
		karma_label.text = "Karma: %s (%d)" % [karma_desc, karma]

func _update_simulation_count():
	"""Update simulation count label"""
	if simulation_count_label:
		var count = StoryStateManager.get_state("simulations_done")
		simulation_count_label.text = "Simulations: %d" % count

func _get_karma_description(karma: int) -> String:
	"""Convert karma value to text"""
	if karma < -70:
		return "Abyssal"
	elif karma < -30:
		return "Demonic"
	elif karma < 0:
		return "Gray"
	elif karma < 30:
		return "Righteous"
	elif karma < 70:
		return "Virtuous"
	else:
		return "Saint"

func _on_health_changed(new_health, max_health):
	"""Handle health change signal"""
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = new_health

func _on_qi_changed(new_qi, max_qi):
	"""Handle qi change signal"""
	if qi_bar:
		qi_bar.max_value = max_qi
		qi_bar.value = new_qi

func _on_realm_breakthrough(new_realm):
	"""Handle realm breakthrough"""
	_update_realm_display()

func _on_world_state_changed(variable_name, old_value, new_value):
	"""Handle world state changes"""
	match variable_name:
		"karma":
			_update_karma_display()
		"simulations_done":
			_update_simulation_count()
