extends CanvasLayer

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	var new_state = !get_tree().paused
	get_tree().paused = new_state
	visible = new_state

func _on_resume_button_pressed():
	get_tree().paused = false
	hide()

func _on_restart_button_pressed():
	get_tree().paused = false
	GameManager.score = 0
	GameManager.lives = 3
	GameManager.health = GameManager.max_health
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
