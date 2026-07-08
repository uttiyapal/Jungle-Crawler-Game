extends Area2D

signal level_completed

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if !body.is_in_group("Player"):
		return

	if !GameManager.has_key:
		print("The door is locked!")
		return

	level_completed.emit()
