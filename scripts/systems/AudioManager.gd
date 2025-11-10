extends Node

# Audio Manager - Handles BGM and SFX

var bgm_player: AudioStreamPlayer
var sfx_players = []
var max_sfx_players = 16

var bgm_volume = 0.5
var sfx_volume = 0.7

var current_bgm = ""

# Audio file paths (to be populated with actual audio files)
var bgm_tracks = {
	"menu": "res://audio/bgm/menu.ogg",
	"exploration": "res://audio/bgm/exploration.ogg",
	"combat": "res://audio/bgm/combat.ogg",
	"simulation": "res://audio/bgm/simulation.ogg",
	"boss": "res://audio/bgm/boss.ogg"
}

var sfx_sounds = {
	"ui_click": "res://audio/sfx/ui_click.wav",
	"ability_unlock": "res://audio/sfx/ability_unlock.wav",
	"cultivation": "res://audio/sfx/cultivation.wav",
	"breakthrough": "res://audio/sfx/breakthrough.wav",
	"attack": "res://audio/sfx/attack.wav",
	"hit": "res://audio/sfx/hit.wav",
	"dash": "res://audio/sfx/dash.wav",
	"death": "res://audio/sfx/death.wav"
}

func _ready():
	_setup_audio_players()

func _setup_audio_players():
	# Create BGM player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	add_child(bgm_player)
	
	# Create SFX players pool
	for i in range(max_sfx_players):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func play_bgm(track_name: String, fade_in: bool = true):
	if current_bgm == track_name and bgm_player.playing:
		return
	
	if not bgm_tracks.has(track_name):
		push_warning("BGM track not found: " + track_name)
		return
	
	# Note: Actual audio files would need to be created
	# For now, this is the structure
	
	current_bgm = track_name
	# bgm_player.stream = load(bgm_tracks[track_name])
	# bgm_player.volume_db = linear2db(bgm_volume)
	# bgm_player.play()

func stop_bgm(fade_out: bool = true):
	if fade_out:
		# TODO: Implement fade out tween
		pass
	bgm_player.stop()
	current_bgm = ""

func play_sfx(sound_name: String, pitch_scale: float = 1.0):
	if not sfx_sounds.has(sound_name):
		return
	
	# Find available player
	for player in sfx_players:
		if not player.playing:
			# player.stream = load(sfx_sounds[sound_name])
			# player.pitch_scale = pitch_scale
			# player.volume_db = linear2db(sfx_volume)
			# player.play()
			return
	
	# All players busy, use first one
	# sfx_players[0].stop()
	# sfx_players[0].stream = load(sfx_sounds[sound_name])
	# sfx_players[0].play()

func set_bgm_volume(volume: float):
	bgm_volume = clamp(volume, 0.0, 1.0)
	bgm_player.volume_db = linear2db(bgm_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear2db(sfx_volume)

func save_to_dict() -> Dictionary:
	return {
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume
	}

func load_from_dict(data: Dictionary):
	if data.has("bgm_volume"):
		set_bgm_volume(data["bgm_volume"])
	if data.has("sfx_volume"):
		set_sfx_volume(data["sfx_volume"])
