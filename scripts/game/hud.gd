extends CanvasLayer

@onready var score_label = $TopBar/ScoreLabel
@onready var lives_label = $TopBar/LivesLabel
@onready var key_label = $TopBar/KeyLabel
@onready var health_label = $TopBar/HealthLabel
@onready var gun_label = $TopBar/GunLabel
@onready var jetpack_label = $TopBar/JetpackLabel

func _process(_delta):
	score_label.text = "Score: %06d" % GameManager.score
	lives_label.text = "Lives: %d" % GameManager.lives
	key_label.text = "Key: " + ("YES" if GameManager.has_key else "NO")
	health_label.text = "Health: %d/%d" % [
	GameManager.health,
	GameManager.max_health
	]
	gun_label.text = "Gun: " + ("YES" if GameManager.has_gun else "NO")
	jetpack_label.text = "Jetpack: " + ("YES" if GameManager.has_jetpack else "NO")
