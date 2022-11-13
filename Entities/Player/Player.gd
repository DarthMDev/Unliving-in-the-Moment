class_name Player
extends KinematicBody

export(int) var MAX_SPEED = 10
export(int) var ACCELERATION = 4
export(int) var FRICTION = 10
export(int) var GRAVITY = 1
export(float) var alpha = 1.0
export (int) var lives = 3
export (int) var MAX_LIVES = 3
onready var CLOTH: SoftBody = $ClothRotation/Cloth
onready var CLOTH_ROTATION = $ClothRotation
onready var ETHEREAL_PLAYER = $EtherealPlayer
onready var ROCKET_LAUNCHER_PLAYER = $RocketLauncherPlayer

onready var ROCKET_LAUNCHER_MESH = $ClothRotation/RocketLauncherMesh

onready var ROCKET_SCENE = load("res://Entities/Rocket/Rocket.tscn")

var lastOnGroundPos = Vector3.ZERO
var lastOnGroundVel = Vector3.ZERO
var material = SpatialMaterial.new()
var velocity = Vector3.ZERO
var player = self
var hidden_mouse = false
var iframes = 0

var knockback_timer = 0

onready var ui = $UserInterface
onready var livesSprite = $"CanvasLayer/UserInterface/LivesCounter/Sprite"
var livesToY = {
	3: 0,
	2: 22,
	1: 44,
	0: 66
}
func _ready():
	material.flags_transparent = true
	CLOTH.material_override = material

	# hide the cursor
func _process(delta):
	if Input.is_action_just_pressed("ethereal"):
		ETHEREAL_PLAYER.play("Ethereal")
	if lives == 0:
		# TODO add death animation
		# ANIMATION_PLAYER.play('Death')
		# TODO add death sound effect
		# reset the scene
		get_tree().reload_current_scene()
		# TODO add death screen

	if Input.is_action_just_pressed("shoot") and not ROCKET_LAUNCHER_PLAYER.is_playing():
		var rocket = ROCKET_SCENE.instance()
		rocket.init($ClothRotation/RocketLauncherMesh/RocketMesh.global_translation, $ClothRotation/RocketLauncherMesh/RocketMesh.global_rotation)
		ROCKET_LAUNCHER_PLAYER.play("Launch")
		get_parent().add_child(rocket)
	
	material.albedo_color = Color(1.0, 1.0, 1.0, alpha)


func _physics_process(delta):
	if iframes > 0:
		iframes -= delta
		
	var x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var z_input = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	var direction = Vector3(x_input, 0, z_input).normalized()
	
	if direction.x == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION)
	
	if direction.z == 0:
		velocity.z = move_toward(velocity.z, 0, FRICTION)
	else:
		velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED, ACCELERATION)
	
	velocity.y += -GRAVITY
	
	if knockback_timer <= 0:
		velocity = lerp(velocity, move_and_slide(velocity * (2.0 if alpha < 1 else 1.0), Vector3.UP, true, 4, deg2rad(45)), delta * 5)
	else:
		knockback_timer-= delta
		move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(45))
		
	var mousePos = getMousePosition3D()
	var mouseDelta = mousePos - translation

	var angle = atan2(mouseDelta.x, mouseDelta.z);

	CLOTH_ROTATION.rotation.y = lerp_angle(CLOTH_ROTATION.rotation.y, angle, delta * 3)

	ROCKET_LAUNCHER_MESH.rotation.y = angle - CLOTH_ROTATION.rotation.y + deg2rad(90)
	
	if velocity.y >= 0:
		lastOnGroundPos = Vector3(player.translation.x, player.global_translation.y, player.global_translation.z)
		lastOnGroundVel = Vector3(velocity.x, velocity.y, velocity.z)
	# if the player is below the ground respawn them back at their previous position
	elif player.global_translation.y < -10:
		# reset the scene
		# get_tree().reload_current_scene()

		player.global_translation = lastOnGroundPos
		velocity = -lastOnGroundVel * 3
		
		fall_damage()
		# minus_lives(1)
	
		player.translation = Vector3(1, 1, 1)

		# TODO reset the player position nearest to their last position on the ground
	
func getMousePosition3D():

	var spaceState = get_world().direct_space_state

	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera()
	var rayOrigin = camera.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + camera.project_ray_normal(mousePos) * 2000
	var rayArray = spaceState.intersect_ray(rayOrigin, rayEnd)

	if rayArray.has("position"):
		return rayArray["position"]
	return Vector3()

func checkLives():
	if lives == 0:
		lives = 0
		# TODO add death GUI animation
		# Game over
	elif lives > MAX_LIVES:
		lives = MAX_LIVES
	else:
		# Respawn and update lives GUI
		pass
		# get_tree().reload_current_scene()
	livesSprite.region_rect  =  Rect2(0, livesToY[lives], 33, 11)

func fall_damage():
	lives -= 1
	checkLives()

func damage(amount):
	if iframes <= 0:
		lives -= amount
		checkLives()
		iframes = 0.1

func get_lives():
	return lives
