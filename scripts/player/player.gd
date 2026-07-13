extends CharacterBody2D

signal player_died
signal game_over

const JETPACK_SPEED := 120.0
var is_shooting := false
var is_hurt := false
var bullet_spawn_offset := 10.0
const SPEED := 100.0
const JUMP_FORCE := -250.0
const GRAVITY := 980.0
var facing_right := true

var is_invincible := false
const INVINCIBILITY_DURATION := 1.0

@export var bullet_scene: PackedScene
@onready var sprite = $AnimatedSprite2D
@onready var bullet_spawn = $BulletSpawn
@onready var camera = $Camera2D
@onready var jetpack_sound = $JetpackSound
@onready var shoot_sound = $ShootSound

var active_bullet: Node = null

func _ready():
	bullet_spawn_offset = abs(bullet_spawn.position.x)

func _physics_process(delta):

	if get_tree().paused:
		return
	
	# Check if the jetpack is being used
	var using_jetpack = (
		GameManager.has_jetpack
		and Input.is_action_pressed("jetpack")
		and GameManager.jetpack_fuel > 0
	)
	
	if using_jetpack:
		if !jetpack_sound.playing:
			jetpack_sound.play()
	else:
		if jetpack_sound.playing:
			jetpack_sound.stop()

	if using_jetpack:

		var fly_direction = Input.get_vector(
			"move_left",
			"move_right",
			"move_up",
			"move_down"
		)

		velocity = fly_direction * JETPACK_SPEED

		# Consume fuel only while moving
		if fly_direction != Vector2.ZERO:
			GameManager.jetpack_fuel = max(
				GameManager.jetpack_fuel - 20 * delta,
				0
			)

		# Face the direction of flight
		if fly_direction.x > 0:
			facing_right = true
			sprite.flip_h = false
			bullet_spawn.position.x = abs(bullet_spawn_offset)

		elif fly_direction.x < 0:
			facing_right = false
			sprite.flip_h = true
			bullet_spawn.position.x = -abs(bullet_spawn_offset)

	else:

		# Gravity
		if !is_on_floor():
			velocity.y += GRAVITY * delta

		# Horizontal movement
		var move_direction = Input.get_axis("move_left", "move_right")
		velocity.x = move_direction * SPEED

		# Face the direction of movement
		if move_direction > 0:
			facing_right = true
			sprite.flip_h = false
			bullet_spawn.position.x = abs(bullet_spawn_offset)

		elif move_direction < 0:
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
	
	add_shake(3.0)
	GameManager.health -= 1

	if GameManager.health <= 0:
		_do_death()

func take_damage(amount: int):
	if is_invincible:
		return

	is_invincible = true
	
	for i in amount:
		damage_player()
	
	await get_tree().create_timer(INVINCIBILITY_DURATION).timeout
	is_invincible = false

func die():
	if is_invincible:
		return

	is_invincible = true
	_do_death()

	await get_tree().create_timer(INVINCIBILITY_DURATION).timeout
	is_invincible = false

func _do_death():
	add_shake(6.0)

	GameManager.lives -= 1
	GameManager.health = GameManager.max_health

	if GameManager.lives <= 0:
		GameManager.lives = 0
		game_over.emit()
		return

	player_died.emit()

func respawn(spawn_position: Vector2):

	global_position = spawn_position
	velocity = Vector2.ZERO
	is_hurt = false
	is_shooting = false

func shoot():
	if !GameManager.has_gun:
		return

	if active_bullet:
		return

	is_shooting = true
	is_hurt = false   # shooting cancels any stale hurt state

	sprite.play("Shoot")
	shoot_sound.play()

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

	if is_hurt:
		return
	
	if is_shooting:
		return

	var using_jetpack = (
		GameManager.has_jetpack
		and Input.is_action_pressed("jetpack")
		and GameManager.jetpack_fuel > 0
	)

	if using_jetpack:
		sprite.play("Jetpack")

	elif !is_on_floor():
		sprite.play("Jump")

	elif abs(velocity.x) > 0:
		sprite.play("Walk")

	else:
		sprite.play("Idle")

func _on_animated_sprite_2d_animation_finished():

	if sprite.animation == "Shoot":
		is_shooting = false

	elif sprite.animation == "Hurt":
		is_hurt = false

func set_camera_limits(top_left: Vector2, bottom_right: Vector2):
	camera.limit_left = int(top_left.x)
	camera.limit_top = int(top_left.y)
	camera.limit_right = int(bottom_right.x)
	camera.limit_bottom = int(bottom_right.y)

func play_hurt():
	is_shooting = false   # getting hurt cancels any stale shoot state
	is_hurt = true
	sprite.play("Hurt")

var shake_strength := 0.0
const SHAKE_DECAY := 5.0

func _process(delta):
	if shake_strength > 0:
		shake_strength = max(shake_strength - SHAKE_DECAY * delta, 0)
		camera.offset = Vector2(
			randf_range(-1, 1) * shake_strength,
			randf_range(-1, 1) * shake_strength
		)
	else:
		camera.offset = Vector2.ZERO

func add_shake(amount: float):
	shake_strength = min(shake_strength + amount, 16.0)
