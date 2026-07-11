extends Node

@onready var background_music = $BackgroundMusic
@onready var current_level = $CurrentLevel
@onready var player = $Player
@onready var hud = $HUD
@onready var pickup_sound = $PickupSound
@onready var game_complete = $GameComplete

var current_level_instance : Node = null

var levels = [
	"res://scenes/levels/Level01.tscn",
	"res://scenes/levels/Level02.tscn",
	"res://scenes/levels/Level03.tscn"
]

var current_level_index = 0

func _ready():
	background_music.play()
	player.player_died.connect(_on_player_died)
	load_level(levels[current_level_index])

func load_level(scene_path: String):
	
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
