extends Area2D

@export var speed := 250.0

var direction : Vector2 = Vector2.RIGHT

@onready var sprite = $AnimatedSprite2D
@onready var notifier = $VisibleOnScreenNotifier2D

func _ready():
	sprite.play("Idle")

	body_entered.connect(_on_body_entered)
	notifier.screen_exited.connect(queue_free)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(1)
		body.play_hurt()

	queue_free()
