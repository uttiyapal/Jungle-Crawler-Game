extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("Idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if !body.is_in_group("Player"):
		return

	GameManager.has_key = true

	print("Key collected!")

	queue_free()
