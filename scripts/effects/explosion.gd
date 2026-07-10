extends Node2D

@onready var sprite = $AnimatedSprite2D

func _ready():

	sprite.play("Explode")

	sprite.animation_finished.connect(_on_finished)

func _on_finished():

	queue_free()
