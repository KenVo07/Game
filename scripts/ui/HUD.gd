extends Control

# HUD - Heads Up Display for player stats

onready var health_bar = $HealthBar
onready var qi_bar = $QiBar
onready var realm_label = $RealmLabel
onready var karma_label = $KarmaLabel
onready var ability_container = $AbilityContainer

func _ready():
	_update_all()
	
	# Connect signals
	CultivationSystem.connect("stats_changed", self, "_on_stats_changed")
	CultivationSystem.connect("realm_breakthrough", self, "_on_realm_breakthrough")
	StoryStateManager.connect("world_state_changed", self, "_on_world_state_changed")

func _process(_delta):
	_update_qi()

func _update_all():
	_update_health()
	_update_qi()
	_update_realm()
	_update_karma()
	_update_abilities()

func _update_health():
	if not health_bar:
		return
	
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		var p = player[0]
		health_bar.max_value = p.max_health
		health_bar.value = p.current_health

func _update_qi():
	if not qi_bar:
		return
	
	qi_bar.max_value = CultivationSystem.stats["qi_capacity"]
	qi_bar.value = CultivationSystem.stats["qi_current"]

func _update_realm():
	if not realm_label:
		return
	
	realm_label.text = "Realm: %s (%d%%)" % [
		CultivationSystem.current_realm,
		int(CultivationSystem.cultivation_progress * 100)
	]

func _update_karma():
	if not karma_label:
		return
	
	var karma = StoryStateManager.world_state["karma"]
	var karma_text = "Karma: %d" % karma
	
	if karma > 50:
		karma_label.add_color_override("font_color", Color(0.2, 1.0, 0.2))
	elif karma < -50:
		karma_label.add_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		karma_label.add_color_override("font_color", Color(1.0, 1.0, 1.0))
	
	karma_label.text = karma_text

func _update_abilities():
	if not ability_container:
		return
	
	# Clear existing
	for child in ability_container.get_children():
		child.queue_free()
	
	# Add active abilities
	var abilities = AbilitySystem.get_active_abilities()
	for ability in abilities:
		var label = Label.new()
		label.text = ability["name"]
		var rank_color = AbilitySystem.get_rank_color(ability.get("rank", "White"))
		label.add_color_override("font_color", rank_color)
		ability_container.add_child(label)

func _on_stats_changed(stat_name, _old_value, _new_value):
	match stat_name:
		"vitality":
			_update_health()
		"qi_current", "qi_capacity":
			_update_qi()
		_:
			pass

func _on_realm_breakthrough(_old_realm, _new_realm):
	_update_realm()

func _on_world_state_changed(variable, _old_value, _new_value):
	if variable == "karma":
		_update_karma()
