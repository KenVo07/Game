extends Control

# ==========================================
# HUD (Heads-Up Display)
# ==========================================
# Main game UI showing player stats

# UI Elements (to be connected in scene)
onready var health_bar = $VBoxContainer/HealthBar
onready var qi_bar = $VBoxContainer/QiBar
onready var realm_label = $VBoxContainer/RealmLabel
onready var karma_label = $VBoxContainer/KarmaLabel
onready var notifications = $NotificationContainer

# Notification queue
var notification_queue = []
var current_notification = null

func _ready():
	# Connect to player signals
	var player = get_player()
	if player:
		player.connect("health_changed", self, "_on_health_changed")
		player.connect("qi_changed", self, "_on_qi_changed")
	
	# Connect to cultivation system
	CultivationSystem.connect("realm_breakthrough", self, "_on_realm_breakthrough")
	CultivationSystem.connect("stat_changed", self, "_on_stat_changed")
	
	# Connect to story state
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")
	
	# Initial update
	update_all_ui()

func _process(delta):
	process_notifications(delta)

# ==========================================
# UI UPDATES
# ==========================================

func update_all_ui():
	"""
	Update all UI elements
	"""
	update_health_bar()
	update_qi_bar()
	update_realm_label()
	update_karma_label()

func update_health_bar():
	"""
	Update health bar
	"""
	var player = get_player()
	if player and health_bar:
		health_bar.max_value = player.max_health
		health_bar.value = player.current_health

func update_qi_bar():
	"""
	Update qi bar
	"""
	var player = get_player()
	if player and qi_bar:
		qi_bar.max_value = player.max_qi
		qi_bar.value = player.current_qi

func update_realm_label():
	"""
	Update realm label
	"""
	if realm_label:
		var realm = CultivationSystem.get_current_realm()
		var progress = CultivationSystem.realm_progress * 100
		realm_label.text = "Realm: %s (%.1f%%)" % [realm, progress]

func update_karma_label():
	"""
	Update karma label
	"""
	if karma_label:
		var karma = StoryStateManager.get_state("karma")
		var karma_text = "Karma: %d " % karma
		
		if karma > 50:
			karma_text += "(Righteous)"
		elif karma > 20:
			karma_text += "(Good)"
		elif karma > -20:
			karma_text += "(Neutral)"
		elif karma > -50:
			karma_text += "(Dark)"
		else:
			karma_text += "(Demonic)"
		
		karma_label.text = karma_text

# ==========================================
# SIGNAL HANDLERS
# ==========================================

func _on_health_changed(current, max_value):
	"""
	Handle health changes
	"""
	if health_bar:
		health_bar.max_value = max_value
		health_bar.value = current

func _on_qi_changed(current, max_value):
	"""
	Handle qi changes
	"""
	if qi_bar:
		qi_bar.max_value = max_value
		qi_bar.value = current

func _on_realm_breakthrough(new_realm):
	"""
	Handle realm breakthrough
	"""
	show_notification("Breakthrough! New Realm: " + new_realm, Color.gold)
	update_realm_label()

func _on_stat_changed(stat_name, old_value, new_value):
	"""
	Handle stat changes
	"""
	if stat_name in ["max_vitality", "vitality", "max_qi"]:
		update_all_ui()

func _on_world_state_changed(variable_name, old_value, new_value):
	"""
	Handle world state changes
	"""
	if variable_name == "karma":
		update_karma_label()
		
		# Show notification for significant karma changes
		var delta = new_value - old_value
		if abs(delta) >= 10:
			var text = "Karma %s%d" % ["+" if delta > 0 else "", delta]
			var color = Color.cyan if delta > 0 else Color.red
			show_notification(text, color)

# ==========================================
# NOTIFICATIONS
# ==========================================

func show_notification(text: String, color: Color = Color.white):
	"""
	Show a notification message
	"""
	notification_queue.append({
		"text": text,
		"color": color,
		"duration": 3.0
	})

func process_notifications(delta):
	"""
	Process notification queue
	"""
	if current_notification:
		current_notification["duration"] -= delta
		if current_notification["duration"] <= 0:
			hide_current_notification()
	
	if not current_notification and notification_queue.size() > 0:
		display_next_notification()

func display_next_notification():
	"""
	Display the next notification in queue
	"""
	if notification_queue.size() == 0:
		return
	
	current_notification = notification_queue.pop_front()
	
	if notifications:
		notifications.text = current_notification["text"]
		notifications.modulate = current_notification["color"]
		notifications.visible = true

func hide_current_notification():
	"""
	Hide current notification
	"""
	if notifications:
		notifications.visible = false
	current_notification = null

# ==========================================
# UTILITY
# ==========================================

func get_player():
	"""
	Get player node
	"""
	return get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
