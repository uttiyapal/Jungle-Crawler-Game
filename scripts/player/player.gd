extends CharacterBody2D

signal player_died

const SPEED := 100.0
const JUMP_FORCE := -250.0
const GRAVITY := 980.0

func _physics_process(delta):

	# Gravity
	if !is_on_floor():
		velocity.y += GRAVITY * delta

	# Movement
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()
	
	if Input.is_action_just_pressed("confirm"):
		damage_player()
	
func damage_player():

	GameManager.health -= 1

	print("Player took damage!")
	print("Health:", GameManager.health)

	if GameManager.health <= 0:
		die()

func die():

	print("Player died!")

	GameManager.lives -= 1

	GameManager.health = GameManager.max_health

	if GameManager.lives <= 0:

		GameManager.lives = 0

		print("GAME OVER")

		return

	player_died.emit()

func respawn(spawn_position: Vector2):

	print("Respawning player.")

	global_position = spawn_position
	velocity = Vector2.ZERO






	
	
	
	
	
	
	
