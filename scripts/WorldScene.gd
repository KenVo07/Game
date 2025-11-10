extends Node2D

# World Scene - Main gameplay scene

onready var player = $Player
onready var camera = $Camera2D
onready var ui = $UI

var save_system

func _ready():
	save_system = preload("res://scripts/SaveLoadSystem.gd").new()
	add_child(save_system)
	
	AudioManager.play_bgm("exploration")
	
	# Setup camera to follow player
	if camera and player:
		camera.position = player.position
	
	# Connect player signals
	if player:
		player.connect("died", self, "_on_player_died")

func _process(_delta):
	# Update camera to follow player
	if camera and is_instance_valid(player):
		camera.global_position = player.global_position
	
	# Quick save
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause():
	get_tree().paused = !get_tree().paused
	# TODO: Show pause menu

func _on_player_died():
	print("Player died! Triggering respawn...")
	# TODO: Implement death/respawn system
	# Could trigger a special simulation or reload

func auto_save():
	if save_system:
		save_system.auto_save()
