extends Control

# ==========================================
# HUD - Head-Up Display
# Shows player stats, cultivation progress, and notifications
# ==========================================

# References
onready var health_bar = $MarginContainer/VBoxContainer/HealthBar
onready var qi_bar = $MarginContainer/VBoxContainer/QiBar
onready var realm_label = $MarginContainer/VBoxContainer/RealmLabel
onready var cultivation_progress = $MarginContainer/VBoxContainer/CultivationProgress
onready var karma_label = $MarginContainer/VBoxContainer/StatsPanel/KarmaLabel
onready var reputation_label = $MarginContainer/VBoxContainer/StatsPanel/ReputationLabel
onready var notification_label = $NotificationLabel
onready var ability_cooldown_container = $AbilityCooldownContainer

var notification_timer: float = 0.0
var notification_duration: float = 3.0


func _ready():
	print("[HUD] Initialized")
	_connect_signals()
	_update_all()


func _connect_signals():
	"""Connect to system signals"""
	# Cultivation System
	CultivationSystem.connect("realm_breakthrough", self, "_on_realm_breakthrough")
	CultivationSystem.connect("cultivation_progress", self, "_on_cultivation_progress")
	CultivationSystem.connect("stat_increased", self, "_on_stat_increased")
	
	# Story State
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")
	StoryStateManager.connect("event_triggered", self, "_on_event_triggered")
	
	# Ability System
	AbilitySystem.connect("ability_unlocked", self, "_on_ability_unlocked")
	
	# Player
	var player = get_tree().get_nodes_in_group("player")
	if not player.empty():
		player[0].connect("health_changed", self, "_on_health_changed")
		player[0].connect("qi_changed", self, "_on_qi_changed")


func _process(delta):
	# Update notification timer
	if notification_timer > 0:
		notification_timer -= delta
		if notification_timer <= 0:
			notification_label.visible = false


# ==========================================
# UPDATE FUNCTIONS
# ==========================================

func _update_all():
	"""Update all HUD elements"""
	_update_health()
	_update_qi()
	_update_realm()
	_update_cultivation_progress()
	_update_karma()
	_update_reputation()


func _update_health():
	"""Update health bar"""
	if not health_bar:
		return
	
	var player = get_tree().get_nodes_in_group("player")
	if player.empty():
		return
	
	var player_node = player[0]
	if player_node.has_method("get"):
		health_bar.max_value = player_node.max_health
		health_bar.value = player_node.current_health


func _update_qi():
	"""Update qi bar"""
	if not qi_bar:
		return
	
	var qi_capacity = CultivationSystem.get_stat("qi_capacity")
	var qi_current = CultivationSystem.get_stat("qi_current")
	
	qi_bar.max_value = qi_capacity
	qi_bar.value = qi_current


func _update_realm():
	"""Update realm label"""
	if realm_label:
		var realm = CultivationSystem.current_realm
		realm_label.text = "Realm: " + realm


func _update_cultivation_progress():
	"""Update cultivation progress bar"""
	if cultivation_progress:
		cultivation_progress.max_value = CultivationSystem.cultivation_required
		cultivation_progress.value = CultivationSystem.cultivation_progress


func _update_karma():
	"""Update karma display"""
	if karma_label:
		var karma = StoryStateManager.get_state("karma")
		karma_label.text = "Karma: %d" % karma
		
		# Color based on karma
		if karma < -30:
			karma_label.add_color_override("font_color", Color.red)
		elif karma > 30:
			karma_label.add_color_override("font_color", Color.cyan)
		else:
			karma_label.add_color_override("font_color", Color.white)


func _update_reputation():
	"""Update reputation display"""
	if reputation_label:
		var reputation = StoryStateManager.get_state("reputation")
		reputation_label.text = "Reputation: %d" % reputation


# ==========================================
# SIGNAL HANDLERS
# ==========================================

func _on_health_changed(current_health, max_health):
	"""Handle player health changes"""
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health


func _on_qi_changed(current_qi, max_qi):
	"""Handle player qi changes"""
	if qi_bar:
		qi_bar.max_value = max_qi
		qi_bar.value = current_qi


func _on_realm_breakthrough(old_realm, new_realm):
	"""Handle cultivation breakthrough"""
	_update_realm()
	show_notification("Breakthrough! %s -> %s" % [old_realm, new_realm], Color.gold)


func _on_cultivation_progress(current_progress, max_progress):
	"""Handle cultivation progress updates"""
	_update_cultivation_progress()


func _on_stat_increased(stat_name, new_value):
	"""Handle stat increases"""
	show_notification("%s increased to %d" % [stat_name.capitalize(), new_value], Color.green)


func _on_world_state_changed(variable_name, old_value, new_value):
	"""Handle world state changes"""
	match variable_name:
		"karma":
			_update_karma()
		"reputation":
			_update_reputation()


func _on_event_triggered(event_name, context):
	"""Handle story events"""
	show_notification("Event: " + event_name.replace("_", " ").capitalize(), Color.yellow)


func _on_ability_unlocked(ability_name, ability_type):
	"""Handle ability unlocks"""
	show_notification("Unlocked: " + ability_name, Color.purple)


# ==========================================
# NOTIFICATIONS
# ==========================================

func show_notification(text: String, color: Color = Color.white):
	"""Display temporary notification"""
	if notification_label:
		notification_label.text = text
		notification_label.modulate = color
		notification_label.visible = true
		notification_timer = notification_duration
		
		print("[HUD] Notification: " + text)


# ==========================================
# BUTTON HANDLERS
# ==========================================

func _on_simulation_button_pressed():
	"""Open simulation menu"""
	get_tree().call_group("ui_manager", "open_simulation_menu")


func _on_inventory_button_pressed():
	"""Open inventory"""
	get_tree().call_group("ui_manager", "open_inventory")


func _on_character_button_pressed():
	"""Open character sheet"""
	get_tree().call_group("ui_manager", "open_character_sheet")
