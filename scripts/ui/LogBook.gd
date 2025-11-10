extends Control

# ==========================================
# LOGBOOK UI
# ==========================================
# Displays simulation history, insights, and world events

# UI Elements
onready var tab_container = $VBoxContainer/TabContainer
onready var simulation_log = $VBoxContainer/TabContainer/Simulations/ScrollContainer/LogText
onready var insights_log = $VBoxContainer/TabContainer/Insights/ScrollContainer/InsightText
onready var events_log = $VBoxContainer/TabContainer/Events/ScrollContainer/EventText
onready var close_button = $VBoxContainer/CloseButton

func _ready():
	visible = false
	
	# Connect close button
	if close_button:
		close_button.connect("pressed", self, "close_logbook")
	
	# Connect to world state changes
	StoryStateManager.connect("event_triggered", self, "_on_event_triggered")

func _input(event):
	"""
	Handle input
	"""
	if event.is_action_pressed("open_logbook") and not visible:
		open_logbook()
	elif event.is_action_pressed("ui_cancel") and visible:
		close_logbook()

# ==========================================
# LOGBOOK CONTROL
# ==========================================

func open_logbook():
	"""
	Open logbook
	"""
	visible = true
	get_tree().paused = true
	
	# Update all logs
	update_all_logs()

func close_logbook():
	"""
	Close logbook
	"""
	visible = false
	get_tree().paused = false

func update_all_logs():
	"""
	Update all log displays
	"""
	update_simulation_log()
	update_insights_log()
	update_events_log()

# ==========================================
# SIMULATION LOG
# ==========================================

func update_simulation_log():
	"""
	Update simulation history log
	"""
	if not simulation_log:
		return
	
	var logs = SimulationManager.get_all_simulations()
	var text = "=== SIMULATION HISTORY ===\n\n"
	
	if logs.size() == 0:
		text += "No simulations recorded yet.\n"
	else:
		for i in range(logs.size()):
			var sim = logs[i]
			var result = sim["simulation_result"]
			var ability = sim["rolled_ability"]
			
			text += "--- Simulation #%d ---\n" % (i + 1)
			text += "Ability: [%s] %s\n" % [ability["rank"], ability["name"]]
			text += "Survival: %d days\n" % result["survival_time"]
			text += "Death: %s\n" % result["death_cause"]
			text += "\n"
	
	simulation_log.text = text

# ==========================================
# INSIGHTS LOG
# ==========================================

func update_insights_log():
	"""
	Update insights log
	"""
	if not insights_log:
		return
	
	var insights = StoryStateManager.get_state("insight_clues")
	var secrets = StoryStateManager.get_state("secrets_revealed")
	
	var text = "=== INSIGHTS & SECRETS ===\n\n"
	
	text += "-- Insights --\n"
	if insights.size() == 0:
		text += "No insights discovered yet.\n\n"
	else:
		for insight in insights:
			text += "• " + insight + "\n"
		text += "\n"
	
	text += "-- Secrets Revealed --\n"
	if secrets.size() == 0:
		text += "No secrets revealed yet.\n"
	else:
		for secret in secrets:
			text += "★ " + secret + "\n"
	
	insights_log.text = text

# ==========================================
# EVENTS LOG
# ==========================================

func update_events_log():
	"""
	Update world events log
	"""
	if not events_log:
		return
	
	var events = StoryStateManager.get_event_history()
	
	var text = "=== WORLD EVENTS ===\n\n"
	
	if events.size() == 0:
		text += "No events recorded yet.\n"
	else:
		# Show most recent events first
		for i in range(events.size() - 1, max(0, events.size() - 20), -1):
			var event = events[i]
			text += format_event(event) + "\n"
	
	events_log.text = text

func format_event(event: Dictionary) -> String:
	"""
	Format an event for display
	"""
	var text = "• "
	
	match event["type"]:
		"state_change":
			text += "%s changed: %s → %s" % [
				event["data"]["variable"],
				event["data"]["old_value"],
				event["data"]["new_value"]
			]
		
		"alliance_formed":
			text += "Alliance formed with " + event["data"]["faction"]
		
		"alliance_broken":
			text += "Alliance broken with " + event["data"]["faction"]
		
		"enemy_declared":
			text += "Declared enemy of " + event["data"]["faction"]
		
		"follower_joined":
			text += event["data"]["npc"] + " joined as follower"
		
		"insight_gained":
			text += "Insight: " + event["data"]["insight"]
		
		"secret_revealed":
			text += "Secret revealed: " + event["data"]["secret"]
		
		"heavenly_tribulation":
			text += "⚡ Heavenly Tribulation triggered!"
		
		"demonic_path_unlocked":
			text += "🔥 Demonic Path unlocked"
		
		"immortal_path_unlocked":
			text += "✨ Immortal Path unlocked"
		
		_:
			text += event["type"].capitalize()
	
	return text

func _on_event_triggered(event_name: String, event_data: Dictionary):
	"""
	Handle new events
	"""
	# Could show notification
	pass

# ==========================================
# STATISTICS
# ==========================================

func show_statistics():
	"""
	Show player statistics
	"""
	var text = "=== STATISTICS ===\n\n"
	
	var karma = StoryStateManager.get_state("karma")
	var reputation = StoryStateManager.get_state("reputation")
	var simulations = StoryStateManager.get_state("simulations_done")
	var realm = CultivationSystem.get_current_realm()
	var heart_sutra = CultivationSystem.heart_sutra
	
	text += "Realm: %s\n" % realm
	text += "Heart Sutra: %s\n" % heart_sutra
	text += "Karma: %d\n" % karma
	text += "Reputation: %d\n" % reputation
	text += "Simulations: %d\n" % simulations
	text += "\n"
	
	text += "-- Abilities --\n"
	var abilities = AbilitySystem.unlocked_abilities
	if abilities.size() == 0:
		text += "None\n"
	else:
		for ability in abilities:
			text += "• [%s] %s\n" % [ability["rank"], ability["name"]]
	
	return text
