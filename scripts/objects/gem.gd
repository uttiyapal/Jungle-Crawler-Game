extends Area2D

@export var score_value := 100
@onready var sprite = $AnimatedSprite2D

func _ready():

	sprite.play("Idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		
		GameManager.add_score(score_value)
		queue_free()
