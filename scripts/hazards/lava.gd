extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():

	sprite.play("Burn")

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if !body.is_in_group("Player"):
		return

	body.die()
