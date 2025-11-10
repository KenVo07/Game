extends Control

# ==========================================
# MAIN MENU
# ==========================================

# UI Elements
onready var new_game_button = $VBoxContainer/NewGameButton
onready var continue_button = $VBoxContainer/ContinueButton
onready var load_game_button = $VBoxContainer/LoadGameButton
onready var settings_button = $VBoxContainer/SettingsButton
onready var quit_button = $VBoxContainer/QuitButton

onready var title_label = $TitleLabel
onready var version_label = $VersionLabel

func _ready():
	# Connect buttons
	if new_game_button:
		new_game_button.connect("pressed", self, "_on_new_game_pressed")
	if continue_button:
		continue_button.connect("pressed", self, "_on_continue_pressed")
	if load_game_button:
		load_game_button.connect("pressed", self, "_on_load_game_pressed")
	if settings_button:
		settings_button.connect("pressed", self, "_on_settings_pressed")
	if quit_button:
		quit_button.connect("pressed", self, "_on_quit_pressed")
	
	# Set title
	if title_label:
		title_label.text = "SIMULATION OF THE ETERNAL PATH\nVILLAIN EDITION"
	
	if version_label:
		version_label.text = "v1.0.0"
	
	# Check if continue is available
	update_continue_button()

func update_continue_button():
	"""
	Enable/disable continue button based on save existence
	"""
	if continue_button:
		var saves = SaveLoadSystem.get_all_saves()
		var has_save = false
		for save in saves:
			if save["exists"]:
				has_save = true
				break
		continue_button.disabled = not has_save

# ==========================================
# BUTTON HANDLERS
# ==========================================

func _on_new_game_pressed():
	"""
	Start a new game
	"""
	AudioManager.play_ui_sound("confirm")
	
	# Initialize new game
	SaveLoadSystem.new_game()
	
	# Load world scene
	get_tree().change_scene("res://scenes/WorldScene.tscn")

func _on_continue_pressed():
	"""
	Continue from last save
	"""
	AudioManager.play_ui_sound("confirm")
	
	# Find most recent save
	var saves = SaveLoadSystem.get_all_saves()
	var most_recent_slot = -1
	var most_recent_time = 0
	
	for save in saves:
		if save["exists"] and save["timestamp"] > most_recent_time:
			most_recent_time = save["timestamp"]
			most_recent_slot = save["slot"]
	
	if most_recent_slot >= 0:
		SaveLoadSystem.load_game(most_recent_slot)
		get_tree().change_scene("res://scenes/WorldScene.tscn")

func _on_load_game_pressed():
	"""
	Open load game menu
	"""
	AudioManager.play_ui_sound("click")
	
	# Open load game menu (would create separate scene)
	show_load_game_menu()

func _on_settings_pressed():
	"""
	Open settings menu
	"""
	AudioManager.play_ui_sound("click")
	
	# Open settings menu (would create separate scene)
	show_settings_menu()

func _on_quit_pressed():
	"""
	Quit game
	"""
	AudioManager.play_ui_sound("cancel")
	get_tree().quit()

# ==========================================
# SUB MENUS
# ==========================================

func show_load_game_menu():
	"""
	Show load game menu
	"""
	# For now, just print saves
	SaveLoadSystem.print_save_info()
	
	# Would create proper UI here
	print("Load game menu - not implemented yet")

func show_settings_menu():
	"""
	Show settings menu
	"""
	print("Settings menu - not implemented yet")
