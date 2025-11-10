extends Node

# ==========================================
# AUDIO MANAGER
# ==========================================
# Manages background music and sound effects

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Volume settings
var master_volume = 1.0
var music_volume = 0.7
var sfx_volume = 0.8

# Current music track
var current_music = ""
var music_tracks = {}

# SFX library
var sfx_library = {}

func _ready():
	print("AudioManager initialized")
	setup_audio_players()

func setup_audio_players():
	"""
	Setup audio stream players
	"""
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

# ==========================================
# MUSIC CONTROL
# ==========================================

func play_music(track_name: String, fade_in: bool = true):
	"""
	Play background music
	"""
	if current_music == track_name and music_player.playing:
		return
	
	current_music = track_name
	
	if music_tracks.has(track_name):
		if fade_in and music_player.playing:
			fade_out_music()
			yield(get_tree().create_timer(0.5), "timeout")
		
		music_player.stream = music_tracks[track_name]
		music_player.play()
		
		if fade_in:
			fade_in_music()
		else:
			music_player.volume_db = linear2db(music_volume * master_volume)

func stop_music(fade_out: bool = true):
	"""
	Stop music
	"""
	if fade_out:
		fade_out_music()
	else:
		music_player.stop()

func fade_in_music(duration: float = 1.0):
	"""
	Fade in music
	"""
	var tween = create_tween()
	tween.tween_method(self, "set_music_volume_db", -80.0, linear2db(music_volume * master_volume), duration)

func fade_out_music(duration: float = 0.5):
	"""
	Fade out music
	"""
	var tween = create_tween()
	tween.tween_method(self, "set_music_volume_db", music_player.volume_db, -80.0, duration)

func set_music_volume_db(value: float):
	"""
	Set music volume in decibels
	"""
	music_player.volume_db = value

# ==========================================
# SFX CONTROL
# ==========================================

func play_sfx(sfx_name: String, volume_multiplier: float = 1.0):
	"""
	Play a sound effect
	"""
	if sfx_library.has(sfx_name):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		player.stream = sfx_library[sfx_name]
		player.volume_db = linear2db(sfx_volume * master_volume * volume_multiplier)
		add_child(player)
		player.play()
		player.connect("finished", player, "queue_free")
	else:
		push_warning("SFX not found: " + sfx_name)

func play_ui_sound(sound_type: String):
	"""
	Play UI sounds (click, hover, etc.)
	"""
	match sound_type:
		"click":
			play_sfx("ui_click")
		"hover":
			play_sfx("ui_hover")
		"confirm":
			play_sfx("ui_confirm")
		"cancel":
			play_sfx("ui_cancel")

# ==========================================
# VOLUME CONTROL
# ==========================================

func set_master_volume(value: float):
	"""
	Set master volume (0.0 to 1.0)
	"""
	master_volume = clamp(value, 0.0, 1.0)
	update_volumes()

func set_music_volume(value: float):
	"""
	Set music volume (0.0 to 1.0)
	"""
	music_volume = clamp(value, 0.0, 1.0)
	update_volumes()

func set_sfx_volume(value: float):
	"""
	Set SFX volume (0.0 to 1.0)
	"""
	sfx_volume = clamp(value, 0.0, 1.0)
	update_volumes()

func update_volumes():
	"""
	Update all audio volumes
	"""
	if music_player:
		music_player.volume_db = linear2db(music_volume * master_volume)

# ==========================================
# ASSET LOADING
# ==========================================

func register_music(track_name: String, path: String):
	"""
	Register a music track
	"""
	var stream = load(path)
	if stream:
		music_tracks[track_name] = stream
		print("Registered music track: ", track_name)
	else:
		push_error("Failed to load music: " + path)

func register_sfx(sfx_name: String, path: String):
	"""
	Register a sound effect
	"""
	var stream = load(path)
	if stream:
		sfx_library[sfx_name] = stream
		print("Registered SFX: ", sfx_name)
	else:
		push_error("Failed to load SFX: " + path)

# ==========================================
# SERIALIZATION
# ==========================================

func get_save_data() -> Dictionary:
	"""
	Get audio settings to save
	"""
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"current_music": current_music
	}

func load_save_data(data: Dictionary):
	"""
	Load audio settings
	"""
	if data.has("master_volume"):
		master_volume = data["master_volume"]
	if data.has("music_volume"):
		music_volume = data["music_volume"]
	if data.has("sfx_volume"):
		sfx_volume = data["sfx_volume"]
	
	update_volumes()
	
	if data.has("current_music") and data["current_music"] != "":
		play_music(data["current_music"], false)
	
	print("Audio settings loaded")

func linear2db(linear: float) -> float:
	"""
	Convert linear volume to decibels
	"""
	if linear <= 0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)
