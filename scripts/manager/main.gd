extends Node

@onready var background_music = $BackgroundMusic
@onready var current_level = $CurrentLevel
@onready var player = $Player
@onready var hud = $HUD
@onready var pickup_sound = $PickupSound
@onready var game_complete = $GameComplete
@onready var game_over = $GameOver
@onready var pause_menu = $PauseMenu
@onready var transition_anim = $TransitionLayer/AnimationPlayer

var current_level_instance : Node = null

#var levels = [
#	"res://scenes/levels/level01.tscn",
#	"res://scenes/levels/level02.tscn",
#	"res://scenes/levels/level03.tscn"
#]

var levels = [
	"res://scenes/levels/level03.tscn"
]

var current_level_index = 0



func _ready():
	background_music.play()
	player.player_died.connect(_on_player_died)
	player.game_over.connect(_on_game_over)
	load_level(levels[current_level_index])

func load_level(scene_path: String):
	await fade_out()
	GameManager.has_key = false
	GameManager.has_gun = false
	GameManager.has_jetpack = false
	GameManager.jetpack_fuel = GameManager.max_jetpack_fuel

	if current_level_instance:
		current_level_instance.queue_free()

	var scene: PackedScene = load(scene_path)
	
	current_level_instance = scene.instantiate()
	current_level.add_child(current_level_instance)
	
	var door = current_level_instance.get_node("Entities/ExitDoor")
	door.level_completed.connect(_on_level_completed)
	
	var spawn = current_level_instance.get_node("SpawnPoints/PlayerSpawn")
	player.global_position = spawn.global_position
	
	var limits = current_level_instance.get_node("CameraLimits")
	var top_left = limits.get_node("TopLeft")
	var bottom_right = limits.get_node("BottomRight")

	player.set_camera_limits(
		top_left.global_position,
		bottom_right.global_position
	)
	await fade_in()

func fade_out():
	transition_anim.play("FadeOut")
	await transition_anim.animation_finished

func fade_in():
	transition_anim.play("FadeIn")
	await transition_anim.animation_finished

func _on_level_completed() -> void:
	current_level_index += 1

	if current_level_index < levels.size():
		call_deferred("load_level", levels[current_level_index])
	else:
		
		current_level_instance.queue_free()
		player.hide()
		hud.hide()
		background_music.stop()
		game_complete.show()
		game_complete.set_score(GameManager.score)

func _on_player_died():

	print("Main received player_died signal.")

	var spawn = current_level_instance.get_node("SpawnPoints/PlayerSpawn")

	player.respawn(spawn.global_position)

func play_pickup_sound():
	pickup_sound.play()

func _on_game_over():
	current_level_instance.queue_free()
	player.hide()
	hud.hide()
	background_music.stop()
	game_over.show()
	game_over.set_score(GameManager.score)

func show_message(text: String, duration: float = 2.0):
	hud.show_message(text, duration)
