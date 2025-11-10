extends Control

# Main Menu

onready var new_game_button = $VBoxContainer/NewGameButton
onready var continue_button = $VBoxContainer/ContinueButton
onready var load_game_button = $VBoxContainer/LoadGameButton
onready var settings_button = $VBoxContainer/SettingsButton
onready var quit_button = $VBoxContainer/QuitButton

var save_system

func _ready():
	AudioManager.play_bgm("menu")
	
	# Initialize save system
	save_system = preload("res://scripts/SaveLoadSystem.gd").new()
	add_child(save_system)
	
	# Connect buttons
	if new_game_button:
		new_game_button.connect("pressed", self, "_on_new_game_pressed")
	
	if continue_button:
		continue_button.connect("pressed", self, "_on_continue_pressed")
		# Disable if no auto-save exists
		continue_button.disabled = not save_system.save_exists(0)
	
	if load_game_button:
		load_game_button.connect("pressed", self, "_on_load_game_pressed")
	
	if settings_button:
		settings_button.connect("pressed", self, "_on_settings_pressed")
	
	if quit_button:
		quit_button.connect("pressed", self, "_on_quit_pressed")

func _on_new_game_pressed():
	AudioManager.play_sfx("ui_click")
	
	# Reset all systems
	_reset_game_state()
	
	# Load world scene
	var _result = get_tree().change_scene("res://scenes/WorldScene.tscn")

func _on_continue_pressed():
	AudioManager.play_sfx("ui_click")
	
	# Load auto-save
	if save_system.load_game(0):
		var _result = get_tree().change_scene("res://scenes/WorldScene.tscn")
	else:
		print("No save file found!")

func _on_load_game_pressed():
	AudioManager.play_sfx("ui_click")
	# TODO: Open load game menu with save slots
	print("Load game menu not yet implemented")

func _on_settings_pressed():
	AudioManager.play_sfx("ui_click")
	# TODO: Open settings menu
	print("Settings menu not yet implemented")

func _on_quit_pressed():
	AudioManager.play_sfx("ui_click")
	get_tree().quit()

func _reset_game_state():
	# This is called when starting a new game
	# Reset all singleton states to default
	pass  # Systems auto-initialize on _ready()
