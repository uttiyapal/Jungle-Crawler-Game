extends CanvasLayer

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel

func set_score(score: int):
	score_label.text = "Score: %06d" % score

func _on_restart_button_pressed():
	GameManager.score = 0
	GameManager.lives = 3
	GameManager.health = GameManager.max_health

	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
