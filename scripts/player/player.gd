extends CharacterBody2D

signal player_died

var is_shooting := false
var bullet_spawn_offset := 10.0
const SPEED := 100.0
const JUMP_FORCE := -250.0
const GRAVITY := 980.0
var facing_right := true

@export var bullet_scene: PackedScene
@onready var sprite = $AnimatedSprite2D
@onready var bullet_spawn = $BulletSpawn
@onready var camera = $Camera2D

var active_bullet: Node = null

func _ready():
	bullet_spawn_offset = abs(bullet_spawn.position.x)

func _physics_process(delta):

	# Gravity
	if !is_on_floor():
		velocity.y += GRAVITY * delta

	# Movement
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED
	
	if direction > 0:
		facing_right = true
		sprite.flip_h = false
		bullet_spawn.position.x = abs(bullet_spawn_offset)

	elif direction < 0:
		facing_right = false
		sprite.flip_h = true
		bullet_spawn.position.x = -abs(bullet_spawn_offset)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()
	
	update_animation()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
func damage_player():

	GameManager.health -= 1

	print("Player took damage!")
	print("Health:", GameManager.health)
	
	if GameManager.health <= 0:
		die()

func take_damage(amount: int):

	for i in amount:
		damage_player()

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

func shoot():

	if !GameManager.has_gun:
		return

	if active_bullet:
		return
	
	is_shooting = true
	sprite.play("Shoot")
	
	active_bullet = bullet_scene.instantiate()

	get_parent().add_child(active_bullet)

	active_bullet.global_position = bullet_spawn.global_position

	if facing_right:
		active_bullet.direction = Vector2.RIGHT
	else:
		active_bullet.direction = Vector2.LEFT

	active_bullet.bullet_destroyed.connect(_on_bullet_destroyed)

func _on_bullet_destroyed():
	active_bullet = null

func update_animation():
	if is_shooting:
		return
	
	if !is_on_floor():
		sprite.play("Jump")

	elif abs(velocity.x) > 0:
		sprite.play("Walk")

	else:
		sprite.play("Idle")

func _on_animated_sprite_2d_animation_finished():

	if sprite.animation == "Shoot":
		is_shooting = false

func set_camera_limits(top_left: Vector2, bottom_right: Vector2):
	camera.limit_left = int(top_left.x)
	camera.limit_top = int(top_left.y)
	camera.limit_right = int(bottom_right.x)
	camera.limit_bottom = int(bottom_right.y)
